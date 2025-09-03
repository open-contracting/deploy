#!/bin/sh

set -eu

/usr/local/bin/wp cron event run --due-now
