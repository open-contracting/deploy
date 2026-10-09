#!/bin/sh

set -eu

find /home/ocds-docs/web/staging/infrastructure -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -exec du -csh {} \+
find /home/ocds-docs/web/staging/profiles -mindepth 2 -maxdepth 2 -type d -mtime +"$1" -exec du -csh {} \+
find /home/ocds-docs/web/staging -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -not -path '*/profiles*' -not -path '*/infrastructure*' -exec du -csh {} \+

# The superseded production builds that delete.sh reaps. A directory a symlink points at is never listed.
live=$(find /home/ocds-docs/web -maxdepth 3 -type l -exec readlink -f {} \; | sort -u)
find /home/ocds-docs/web -maxdepth 3 -type d -regex '.*-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -mtime +"$1" | while read -r directory; do
    if ! printf '%s\n' "$live" | grep -Fxq "$(readlink -f "$directory")"; then
        printf '%s\n' "$directory"
    fi
done | tr '\n' '\0' | xargs -0 --no-run-if-empty du -csh
