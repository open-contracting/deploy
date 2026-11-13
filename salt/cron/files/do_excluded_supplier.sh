#!/usr/bin/env bash

set -euo pipefail

# If `curl` or `grep` fails, leave the table as it was.
dir=$(mktemp -d)
trap 'rm -rf "$dir"' EXIT

# https://datosabiertos.dgcp.gob.do/opendata/tablas
curl -sSf -o "$dir/proveedores.csv" 'https://datosabiertos.dgcp.gob.do/api-dgcp/v1/tablas/proveedores?Type=csv&inhabilitados=true'

# The first column is the RPE. grep fails if no matches.
grep -Eo '^[0-9]+,' "$dir/proveedores.csv" |
    # Sort numerically and uniquely.
    sort -nu |
    # Prefix the identifier scheme.
    sed -E 's/^(.+),$/DO-RPE-\1/' > "$dir/identifiers.txt"

# Replace the table in a transaction.
psql -U kingfisher_collect -h localhost -q -c "BEGIN; DELETE FROM excluded_supplier; COPY excluded_supplier (identifier) FROM stdin; END;" < "$dir/identifiers.txt"
