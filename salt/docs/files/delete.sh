#!/bin/sh

set -eu

find /home/ocds-docs/web/staging/infrastructure -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -exec rm -r "{}" \;
find /home/ocds-docs/web/staging/profiles -mindepth 2 -maxdepth 2 -type d -mtime +"$1" -exec rm -r "{}" \;
find /home/ocds-docs/web/staging -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -not -path '*/profiles*' -not -path '*/infrastructure*' -exec rm -r "{}" \;
