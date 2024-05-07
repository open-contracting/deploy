#!/usr/bin/env bash
# shellcheck disable=SC1083

set -euo pipefail

cd {{ directory }}

.ve/bin/scrapy crawl \
    {{ crawl.spider }}{% if 'spider_arguments' in crawl %} {{ crawl.spider_arguments }}{% endif %} \
    -a crawl_time={{ crawl.start_date }}T00:00:00 \
    -s FILES_STORE={{ userdir }}/data \
    -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect \
    -s SENTRY_DSN={{ SENTRY_DSN }} \
    --logfile="{{ userdir }}/logs/{{ crawl.spider }}-$(date +%F).log"

# shellcheck disable=all
{%- if 'powerbi' in crawl and crawl.powerbi %}
psql -U kingfisher_collect -h localhost -t -c 'SELECT data FROM {{ crawl.spider }}' -o {{ scratchdir }}/{{ crawl.spider }}.jsonl

ocdscardinal prepare \
    -s {{ settingsdir }}/{{ crawl.spider }}.ini \
    -o {{ scratchdir }}/{{ crawl.spider }}.out.jsonl \
    -e {{ scratchdir }}/{{ crawl.spider }}.err.csv \
    {{ scratchdir }}/{{ crawl.spider }}.jsonl

ocdscardinal indicators \
    -s {{ settingsdir }}/{{ crawl.spider }}.ini \
    --count \
    --map \
    {{ scratchdir }}/{{ crawl.spider }}.out.jsonl \
    > {{scratchdir}}/{{crawl.spider}}.json

{{ userdir }}/bin/manage.py json-to-csv {{ scratchdir }}/{{ crawl.spider }}.json {{ scratchdir }}/{{ crawl.spider }}.csv

psql postgresql://kingfisher_collect@localhost:5432/kingfisher_collect \
    -c "BEGIN" \
    -c "DELETE FROM {{ crawl.spider }}_result" \
    -c "\copy {{ crawl.spider }}_result (ocid, subject, code, result, buyer_id, procuring_entity_id, tenderer_id, created_at) FROM stdin DELIMITER ',' CSV HEADER" \
    -c "END" \
    < {{scratchdir}}/{{crawl.spider}}.csv
{%- endif %}
