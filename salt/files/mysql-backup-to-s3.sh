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

# shellcheck disable=SC1091
source /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

MYSQL="/usr/bin/mysql"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL_DEFAULTS_FILE="/home/sysadmin-tools/mysql-defaults.cnf"

if [ "${LOGNAME}" != "root" ]; then
    echo "ERROR: Execution of ${0} stopped as not run by user root!"
    exit 3
fi

if [ ! -x "${AWS_CLI}" ]; then
    echo "Error: The aws executable is not installed"
    exit 3
fi

if [ -r "${MYSQL_DEFAULTS_FILE}" ]; then
    MYSQL_ARGUMENT="--defaults-extra-file=${MYSQL_DEFAULTS_FILE}"
else
    echo "Error: No database user or defaults file has been set"
    exit 5
fi

mapfile -t DATABASES < <(${MYSQL} "${MYSQL_ARGUMENT}" -Bse 'SHOW DATABASES')
for DATABASE in "${DATABASES[@]}"; do
    case "${DATABASE}" in
    information_schema | performance_schema | sys | innodb | mysql) ;; # Skip system databases
    *)
        TIMESTAMP="$(TZ=UTC date +%Y-%m-%d_%H:%M:%S)"
        TMPFILE="$(mktemp mysql_backup_XXXX.sql.gz)"
        ${MYSQLDUMP} "${MYSQL_ARGUMENT}" --databases "${DATABASE}" | gzip > "${TMPFILE}"
        if zgrep -q "Dump completed on" "${TMPFILE}"; then
            $AWS_CLI s3 cp "${TMPFILE}" "s3://${S3_DATABASE_BACKUP_BUCKET}/${TIMESTAMP}_${DATABASE}.sql.gz" --only-show-errors
        else
            echo "Error: Database ${DATABASE} failed to dump. See ${TMPFILE}"
            break
        fi
        rm "${TMPFILE}"
        ;;
    esac
done
