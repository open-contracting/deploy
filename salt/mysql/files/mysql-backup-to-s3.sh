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

mapfile -t databases < <(/usr/bin/mysql --defaults-extra-file=/home/sysadmin-tools/mysql-defaults.cnf -Bse 'SHOW DATABASES')

for database in "${databases[@]}"; do
    case "$database" in
    information_schema | performance_schema | sys | innodb | mysql) ;; # Skip system databases
    *)
        base_name="$(TZ=UTC date +%Y%m%dT%H%M%SZ)_$database.sql.gz"
        temp_file="$(mktemp /tmp/mysql_backup_XXXX.sql.gz)"

        non_innodb="$(/usr/bin/mysql --defaults-extra-file=/home/sysadmin-tools/mysql-defaults.cnf -Bse "SELECT table_name FROM information_schema.tables WHERE table_schema = '$database' AND engine <> 'InnoDB'")"
        if [ -z "$non_innodb" ]; then
            consistency=(--single-transaction --quick)
        else
            consistency=()
            echo "Warning: $database is dumped with table locking, as these tables are not InnoDB:"
            echo "$non_innodb"
        fi

        /usr/bin/mysqldump --defaults-extra-file=/home/sysadmin-tools/mysql-defaults.cnf "${consistency[@]}" --databases "$database" | gzip > "$temp_file"
        if zgrep -q "Dump completed on" "$temp_file"; then
            $AWS_CLI s3 cp "$temp_file" "s3://$S3_DATABASE_BACKUP_BUCKET/$base_name" --only-show-errors
        else
            echo "Error: Failed to dump $database (see $temp_file)"
            break
        fi

        rm "$temp_file"
        ;;
    esac
done
