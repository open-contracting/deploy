#!/usr/bin/env bash
#
# Backup PostgreSQL databases and upload to AWS S3

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

mapfile -t databases < <(su - postgres -c "/usr/bin/psql -t --csv -c 'select datname from pg_database'")

for database in "${BACKUP_DATABASES[@]}"; do
    if [[ "${databases[*]}" =~ $database ]]; then
        base_name="$(TZ=UTC date +%Y%m%dT%H%M%SZ)_$database.tar"
        temp_file="$(mktemp /tmp/postgres_backup_XXXX.tar)"
        chown postgres:postgres "$temp_file"

        # -Ft exports the database as a .tar file suitable for pg_restore.
        su - postgres -c "/usr/bin/pg_dump -Ft -f '$temp_file' '$database'"

        $AWS_CLI s3 cp "$temp_file" "s3://$S3_DATABASE_BACKUP_BUCKET/$base_name" --only-show-errors
        rm "$temp_file"
    else
        echo "Warning: Database $database does not exist in PostgreSQL."
    fi
done
