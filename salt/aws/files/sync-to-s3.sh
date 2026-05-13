#!/usr/bin/env bash
#
# Sync a single directory into S3.

set -euo pipefail

# shellcheck disable=SC1091
. /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

export AWS_CONFIG_FILE=/home/sysadmin-tools/aws-config.local
export AWS_PROFILE=sync

if [ "$LOGNAME" != "root" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

if [ ! -x "$AWS_CLI" ]; then
    echo "Error: The aws executable is not installed"
    exit 3
fi

if [ -z "$S3_SYNC_BUCKET" ]; then
    echo "Error: S3_SYNC_BUCKET isn't set or is empty"
    exit 4
fi

if [ ! -e "$1" ]; then
    echo "Error: DIRECTORY isn't set or doesn't exist."
    exit 5
fi

DIRECTORY=$1
SAFENAME=${DIRECTORY/#\//}
SAFENAME="${SAFENAME/%\//}"
shift

AWS_ARGS=(--only-show-errors --delete "${@}")

set +e
$AWS_CLI s3 sync "${AWS_ARGS[@]}" "$DIRECTORY" "s3://$S3_SYNC_BUCKET/$SAFENAME/"
set -e
