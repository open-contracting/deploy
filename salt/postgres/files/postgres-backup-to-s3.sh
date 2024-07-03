#!/usr/bin/env bash
#
# Backup PostgreSQL databases and upload to AWS S3

set -euo pipefail

# shellcheck disable=SC1091
. /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

if [ "$LOGNAME" != "postgres" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user postgres!"
    exit 2
fi

if [ ! -x "$AWS_CLI" ]; then
    echo "Error: The aws executable is not installed"
    exit 3
fi

# Create work directory resolving permissions alerts when running psql from root.
WORKDIR=$(mktemp -d)
chown postgres:postgres "$WORKDIR"

mapfile -t DATABASES < <(cd "$WORKDIR" && sudo -u postgres /usr/bin/psql -t --csv -c 'select datname from pg_database')

# Using read over mapfile because the latter leaves a newline on the final item when processing a space delimited string.
read -ra REQUESTED_DATABASES <<< "$BACKUP_DATABASES"

for DATABASE in "${REQUESTED_DATABASES[@]}"; do
    if [[ "${DATABASES[*]}" =~ $DATABASE ]]; then
        BASENAME="$(TZ=UTC date +%Y-%m-%d_%H:%M:%S)_$DATABASE.tar.gz"
        TEMPFILE="$(mktemp postgres_backup_XXXX.tar.gz)"

        # -Ft exports the database as a .tar file suitable for pg_restore.
        (cd "$WORKDIR" && sudo -u postgres /usr/bin/pg_dump -Ft -f "$TEMPFILE" "$DATABASE")

        $AWS_CLI s3 cp "$TEMPFILE" "s3://$S3_DATABASE_BACKUP_BUCKET/$BASENAME" --only-show-errors
        rm "$TEMPFILE"
    else
        echo "Warning: Database $DATABASE does not exist in PostgreSQL."
    fi
done

rmdir "$WORKDIR"
