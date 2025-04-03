#!/usr/bin/env bash
#
# Backup MySQL databases and upload to AWS S3

set -euo pipefail

# shellcheck disable=SC1091
. /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

if [ "$LOGNAME" != "root" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

if [ ! -x "$AWS_CLI" ]; then
    echo "Error: The aws executable is not installed"
    exit 3
fi

if [ ! -r "/home/sysadmin-tools/mysql-defaults.cnf" ]; then
    echo "Error: /home/sysadmin-tools/mysql-defaults.cnf doesn't exist or isn't readable"
    exit 4
fi

mapfile -t DATABASES < <(/usr/bin/mysql --defaults-extra-file=/home/sysadmin-tools/mysql-defaults.cnf -Bse 'SHOW DATABASES')

for DATABASE in "${DATABASES[@]}"; do
    case "$DATABASE" in
    information_schema | performance_schema | sys | innodb | mysql) ;; # Skip system databases
    *)
        BASENAME="$(TZ=UTC date +%Y%m%dT%H%M%SZ)_$DATABASE.sql.gz"
        TEMPFILE="$(mktemp /tmp/mysql_backup_XXXX.sql.gz)"

        /usr/bin/mysqldump --defaults-extra-file=/home/sysadmin-tools/mysql-defaults.cnf --databases "$DATABASE" | gzip > "$TEMPFILE"
        if zgrep -q "Dump completed on" "$TEMPFILE"; then
            $AWS_CLI s3 cp "$TEMPFILE" "s3://$S3_DATABASE_BACKUP_BUCKET/$BASENAME" --only-show-errors
        else
            echo "Error: Failed to dump $DATABASE (see $TEMPFILE)"
            break
        fi

        rm "$TEMPFILE"
        ;;
    esac
done
