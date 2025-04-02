#!/usr/bin/env bash
#
# Backup multiple directories and upload to AWS S3

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

if [ -z "$BACKUP_DIRECTORIES" ]; then
    echo "Error: BACKUP_DIRECTORIES isn't set or is empty"
    exit 4
fi

for DIRECTORY in "${BACKUP_DIRECTORIES[@]}"; do
    SAFENAME="${DIRECTORY//[^a-zA-Z0-9]/_}"
    SAFENAME="${SAFENAME/#_/}"
    SAFENAME="${SAFENAME/%_/}"
    BASENAME="${SAFENAME}_backup_$(TZ=UTC date +%Y%m%dT%H%M%SZ).tar.gz"
    TEMPFILE="$(mktemp /tmp/site_backup_XXXX.tar.gz)"

    # tar will return an exit code if a file is changed (e.g. log) or removed (e.g. cache).
    # The backup of all sites should continue, regardless.
    set +e
    if [ -z "$BACKUP_EXCLUDE" ]; then
        tar czf "$TEMPFILE" "$DIRECTORY" > /dev/null 2>&1
    else
        tar czf "$TEMPFILE" "$DIRECTORY" "$BACKUP_EXCLUDE" > /dev/null 2>&1
    fi
    set -e

    $AWS_CLI s3 cp "$TEMPFILE" "s3://$S3_SITE_BACKUP_BUCKET/$BASENAME" --only-show-errors
    rm "$TEMPFILE"
done
