#!/bin/sh
# Extendable script for custom system metrics
# https://prometheus.io/docs/instrumenting/exposition_formats/

set -eu

## Mail Queue size
MAILQUEUECOUNT=$(postqueue -j | wc -l)
echo "mail_queue_size $MAILQUEUECOUNT"

## mbox size
(
    cd /var/spool/mail/
    for user in *; do
        if [ -f "$user" ]; then
            # If the mailbox is zero, grep returns a non-zero exit code.
            MBOXCOUNT=$(grep -c "^From " "$user" || true)
            echo "mail_box_size[$user] $MBOXCOUNT"
        fi
    done
)
