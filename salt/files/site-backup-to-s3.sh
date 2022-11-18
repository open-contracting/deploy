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

source /home/sysadmin-tools/aws-settings.local

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION

if [ -z "$FOLDER2S3BACKUPSRC" ]; then
    echo "Error: The variables FOLDER2S3BACKUPSRC have not been set"
    exit 4
fi

if [ ! -x $AWS_CLI ]; then
    echo "Error: The aws executable is not installed"
    exit 7
fi

for SITE in "${FOLDER2S3BACKUPSRC[@]}"; do
    # Needs unique name for multi site but not break single site
    SITENAME=$(echo "${SITE//[^a-zA-Z0-9]/_}")
    TIMESTAMP="$(TZ=UTC date +%Y-%m-%d)"
    LOCALBACKUPLOCATION="/tmp/live${SITENAME}backup_${TIMESTAMP}.tar.gz"

    # To stop the script breaking when reading changing files (e.x. logs)
    set +e
    if [ -z "${BACKUPEXCLUDE}" ]; then
        tar czf "${LOCALBACKUPLOCATION}" "${SITE}" &> /dev/null
    else
        tar czf "${LOCALBACKUPLOCATION}" "${SITE}" "${BACKUPEXCLUDE}" &> /dev/null
    fi
    set -e
    ${AWS_CLI} s3 cp "${LOCALBACKUPLOCATION}" s3://${S3BACKUPBUCKET}/live${SITENAME}backup_${TIMESTAMP}.tar.gz --quiet
    rm "${LOCALBACKUPLOCATION}"
done
