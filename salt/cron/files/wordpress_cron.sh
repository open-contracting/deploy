#!/bin/sh

set -eu

/usr/local/bin/wp cron event run --due-now 2>&1 | grep -v "Warning: *Undefined array key"
