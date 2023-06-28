#!/usr/bin/env bash
if [ "$1" = "{{ pillar.postgres.ssl.servername }}" ]; then
  sudo /opt/postgresql-certificates.sh "$1"
fi
