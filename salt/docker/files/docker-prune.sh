#!/bin/sh
#
# Tidy up unused Docker resources, including: stopped containers, unused networks, unused images and old build caches.

set -eu

if [ "$LOGNAME" != "root" ]; then
    echo "ERROR: Execution of $0 stopped as not run by user root!"
    exit 2
fi

# Remove unused containers created over 7 days ago.
docker system prune -af --filter "until=$((7 * 24))h" > /dev/null
