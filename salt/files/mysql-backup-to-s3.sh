#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  Backup MySQL databases and upload to AWS S3
#
# Usage:  $0
#

set -euo pipefail

MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"

source /home/sysadmin-tools/aws-settings.local

# For storing the backups before pushing into AWS
TMPFILE=$(mktemp)
TMPLOG=$(mktemp)

# If a backup fails we want detailed output
function echo_debug {
    echo "$(date +%Y-%m-%dT%H:%M:%S): ${*}" >> "${TMPLOG}"
}

# Enabling debug mode
echo_debug "Backup script starting"

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

if [ -r "${DB_DEFAULTS_FILE}" ]; then
    MYSQL_CMD_LOGIN="--defaults-extra-file=${DB_DEFAULTS_FILE}"
else
    echo "Error: No database connection file has been set"
    exit 1
fi

if [ ! -x "${AWS_CLI}" ]; then
    echo "Error: The aws executable is not installed"
    exit 1
fi

DBS="$(${MYSQL} "${MYSQL_CMD_LOGIN}" -Bse 'show databases')"

for DB in ${DBS}; do
    # Skip system databases. We only want site DB's.
    if [ "${DB}" != "information_schema" ] && [ "${DB}" != "performance_schema" ] && [ "${DB}" != "mysql" ] && [ "${DB}" != "sys" ] && [ "${DB}" != "innodb" ]; then
        attempt=1
        # Temporary DB Dump failed variable which resets after each database backup.
        DBFAILED="true"
        # Retry all backups 4 times before moving onto the next one
        while [ ${attempt} -le 4 ]; do
            sleep 10m
            echo_debug "Starting dump attempt ${attempt}: ${DB}. "
            # Append errors to the debug error log. Otherwise output to the backup file
            timeout 1200 ${MYSQLDUMP} "${MYSQL_CMD_LOGIN}" ${DB_FLAGS} --databases "${DB}" 2>> "${TMPLOG}" | gzip > "${TMPFILE}"
            echo_debug "Dump EC: $?. "
            zgrep "Dump completed on" "${TMPFILE}" >> "${TMPLOG}"
            if [ "$?" -eq 0 ]; then
                DBFAILED="false"
                break
            fi
            echo_debug "WARNING: Non-zero error code for dump attempt ${attempt}: ${DB}."
            ((attempt++))
        done
        # Toggle DEBUG_MODE to true if the backup failed
        if [ "${DBFAILED}" == "true" ]; then
            DEBUG_MODE=${DEBUG_MODE:-"true"}
        fi
        TIMESTAMP="$(TZ=UTC date +%Y-%m-%d_%H:%M:%S)"
        $AWS_CLI s3 cp "$TMPFILE" "s3://$S3DATABASEBACKUPBUCKET/${HOSTNAME}_${DB}_${TIMESTAMP}.sql.gz" --only-show-errors
        echo_debug "AWS copy EC: $?."
    fi
done

# If debug mode is enabled print debug output
if [ "${DEBUG_MODE:-"false"}" == "true" ]; then
    cat "${TMPLOG}"
fi

rm -f "${TMPFILE}"
rm -f "${TMPLOG}"
