#!/bin/sh
#
# Remove files older than X days
#
# Usage: $0 <how many days to keep files> <path to look under>

set -eu

DAYSTOKEEP=$1
RMPATH=$2

# Don't remove the base directory.
touch "$RMPATH"

find "$RMPATH" -mtime +"$DAYSTOKEEP" -type f -delete
find "$RMPATH" -mtime +"$DAYSTOKEEP" -type d -empty -delete
