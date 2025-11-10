#!/bin/sh
# Extendable script for custom system metrics

set -eu

## Collect metrics
MAILQUEUECOUNT=$(postqueue -j | wc -l)

## Print Prometheus formatted data
# https://prometheus.io/docs/instrumenting/exposition_formats/
echo "mail_queue_size $MAILQUEUECOUNT"
