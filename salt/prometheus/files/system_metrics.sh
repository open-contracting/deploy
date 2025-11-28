#!/bin/sh
#
# Extendable script for custom system metrics
# https://prometheus.io/docs/instrumenting/exposition_formats/

set -eu

echo "mail_queue_size $(postqueue -j | wc -l)"

(
    cd /var/spool/mail/
    for user in *; do
        if [ -f "$user" ]; then
            # If the mailbox is empty, grep returns "0" with a non-zero exit code.
            echo "mail_box_size{user=\"$user\"} $(grep -c "^From " "$user" || true)"
        fi
    done
)
