#!/bin/sh

set -eu

find /home/ocds-docs/web/staging/infrastructure -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -exec rm -r "{}" \;
find /home/ocds-docs/web/staging/profiles -mindepth 2 -maxdepth 2 -type d -mtime +"$1" -exec rm -r "{}" \;
find /home/ocds-docs/web/staging -mindepth 1 -maxdepth 1 -type d -mtime +"$1" -not -path '*/profiles*' -not -path '*/infrastructure*' -exec rm -r "{}" \;

# deploy-docs.sh writes each build to a directory suffixed with the Unix time, then moves a symlink onto it, so
# that a bad deploy is reverted by moving the symlink back. Nothing reaped the superseded ones, which is why they
# reached back to 2021. Never delete a directory that a symlink points at, whatever its age.
live=$(find /home/ocds-docs/web -maxdepth 3 -type l -exec readlink -f {} \; | sort -u)
find /home/ocds-docs/web -maxdepth 3 -type d -regex '.*-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' -mtime +"$1" | while read -r directory; do
    if ! printf '%s\n' "$live" | grep -Fxq "$(readlink -f "$directory")"; then
        rm -r "$directory"
    fi
done
