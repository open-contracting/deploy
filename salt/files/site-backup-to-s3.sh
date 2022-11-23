#!/usr/bin/env bash
#
# This file is managed by Dogsbody Technology Ltd.
#   https://www.dogsbody.com/
#
# Description:  Backup multiple directories and upload to AWS S3
#
# Usage:  $0
#

set -euo pipefail

# shellcheck disable=SC1091
source /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

if [ "${LOGNAME}" != "root" ]; then
    echo "ERROR: Execution of ${0} stopped as not run by user root!"
    exit 3
fi

if [ ! -x "${AWS_CLI}" ]; then
    echo "Error: The aws executable is not installed"
    exit 7
fi

if [ -z "$BACKUP_DIRECTORIES" ]; then
    echo "Error: The variables BACKUP_DIRECTORIES have not been set"
    exit 4
fi

for DIRECTORY in "${BACKUP_DIRECTORIES[@]}"; do
    SAFENAME="${DIRECTORY//[^a-zA-Z0-9]/_}"
    SAFENAME="${SAFENAME/#_/}"
    SAFENAME="${SAFENAME/%_/}"
    BASENAME="${SAFENAME}_backup_$(TZ=UTC date +%Y-%m-%d).tar.gz"
    FILEPATH="$(mktemp file_backup_XXXX.tar.gz)"

    # To stop the script breaking when reading changing files (e.x. logs)
    set +e
    if [ -z "${BACKUP_EXCLUDE}" ]; then
        tar czf "${FILEPATH}" "${DIRECTORY}" &> /dev/null
    else
        tar czf "${FILEPATH}" "${DIRECTORY}" "${BACKUP_EXCLUDE}" &> /dev/null
    fi
    set -e

    ${AWS_CLI} s3 cp "${FILEPATH}" "s3://${S3_SITE_BACKUP_BUCKET}/${BASENAME}" --only-show-errors
    rm "${FILEPATH}"
done
