#!/usr/bin/env bash

set -xeuo pipefail

TIMESTAMP=$(date +%s)

if [ "$PRODUCTION" == "true" ]; then
    PREFIX=""
    SUFFIX=-"${TIMESTAMP}"
else
    PREFIX="staging/"
    SUFFIX=""
fi

curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true
rsync -az --delete-after build/ ocds-docs@standard.open-contracting.org:web/"$PREFIX""$PATH_PREFIX""${GITHUB_REF##*/}""$SUFFIX"

ocdsindex sphinx build/ https://standard.open-contracting.org/"$INFIX""$PATH_PREFIX""${GITHUB_REF##*/}"/ > documents.json
ocdsindex index https://standard.open-contracting.org:9200 documents.json

if [ "$PRODUCTION" == "true" ]; then
    curl --silent --connect-timeout 1 standard.open-contracting.org:8255 || true
    ssh ocds-docs@standard.open-contracting.org "ln -nfs ${GITHUB_REF##*/}-${TIMESTAMP} /home/ocds-docs/web/$PATH_PREFIX${GITHUB_REF##*/}"
fi
