#!/usr/bin/env bash

set -euo pipefail

# https://datosabiertos.dgcp.gob.do/opendata/tablas
curl -sSk https://api.dgcp.gob.do/opendata/proveedores/proveedores_inhabilitados.csv |
    # The first column is the RPE.
    grep -Eo '^[0-9]+,' |
    # Sort numerically and uniquely.
    sort -nu |
    # Prefix the identifier scheme.
    sed -E 's/^(.+),$/DO-RPE-\1/' |
    # Replace the table in a transaction.
    psql postgresql://kingfisher_collect@localhost/kingfisher_collect -q -c \
        "BEGIN; DELETE FROM excluded_supplier; COPY excluded_supplier (identifier) FROM stdin; END;"
