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

AWS_ARGS=(--only-show-errors --delete)

# Parse script arguments
while [[ $# -gt 0 ]]; do
    case $1 in
    --exclude)
        if [ -z "$2" ]; then
            echo "Missing path."
            exit 1
        fi
        AWS_ARGS+=(--exclude "\"$2\"")
        shift 2
        ;;
    -*)
        echo "Unknown option"
        exit 1
        ;;
    *)
        DIRECTORY=$1
        SAFENAME=${DIRECTORY/#\//}
        SAFENAME="${SAFENAME/%\//}"
        shift
        ;;
    esac
done

if [ -e "$DIRECTORY" ]; then
    echo "Error: DIRECTORY isn't set or doesn't exist."
    exit 5
fi

set +e
$AWS_CLI s3 sync "${AWS_ARGS[@]}" "$DIRECTORY" "s3://$S3_SYNC_BUCKET/$SAFENAME/"
set -e
