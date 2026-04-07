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

if [ -z "$SYNC_DIRECTORIES" ]; then
    echo "Error: SYNC_DIRECTORIES isn't set or is empty"
    exit 4
fi

for DIRECTORY in "${SYNC_DIRECTORIES[@]}"; do
    SAFENAME="${DIRECTORY/#\//}"
    SAFENAME="${SAFENAME/%\//}"

    $AWS_CLI s3 sync "$DIRECTORY" "s3://$S3_SYNC_BUCKET/$BASENAME/" --only-show-errors --delete
done
