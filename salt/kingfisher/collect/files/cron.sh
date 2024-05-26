#!/bin/sh
# shellcheck disable=SC1083

set -eu

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

{{ userdir }}/.cargo/bin/ocdscardinal prepare \
    -s {{ settingsdir }}/{{ crawl.spider }}.ini \
    -o {{ scratchdir }}/{{ crawl.spider }}.out.jsonl \
    -e {{ scratchdir }}/{{ crawl.spider }}.err.csv \
    {{ scratchdir }}/{{ crawl.spider }}.jsonl

if [ $(stat -c %s {{ scratchdir }}/{{ crawl.spider }}.err.csv) = 0 ]; then
    echo "{{ scratchdir }}/{{ crawl.spider }}.jsonl contains new errors"
    exit 1
fi

{{ userdir }}/.cargo/bin/ocdscardinal indicators \
    -s {{ settingsdir }}/{{ crawl.spider }}.ini \
    --map \
    {{ scratchdir }}/{{ crawl.spider }}.out.jsonl \
    > {{scratchdir}}/{{crawl.spider}}.json

# This appends to the CSV file, to keep flags consistent over time. Delete it manually if results are incorrect.
{{ userdir }}/bin/manage.py json-to-csv -q {{ scratchdir }}/{{ crawl.spider }}.json {{ scratchdir }}/{{ crawl.spider }}.csv

psql -U kingfisher_collect -h localhost -q \
    -c "BEGIN" \
    -c "DROP TABLE IF EXISTS {{ crawl.spider }}_clean" \
    -c "CREATE TABLE {{ crawl.spider }}_clean (data jsonb)" \
    -c "\copy {{ crawl.spider }}_clean (data) FROM stdin CSV QUOTE e'\x01' DELIMITER e'\x02'" \
    -c "CREATE INDEX idx_{{ crawl.spider }}_clean ON {{ crawl.spider }}_clean (cast(data->>'date' as text))" \
    -c "END" \
    < {{scratchdir}}/{{crawl.spider}}.out.jsonl

psql -U kingfisher_collect -h localhost -q \
    -c "BEGIN" \
    -c "DROP TABLE IF EXISTS {{ crawl.spider }}_result" \
    -f {{ userdir }}/bi/sql/{{ crawl.spider }}_result.sql \
    -c "\copy {{ crawl.spider }}_result (ocid, subject, code, result, buyer_id, procuring_entity_id, tenderer_id, created_at) FROM stdin DELIMITER ',' CSV HEADER" \
    -c "END" \
    < {{scratchdir}}/{{crawl.spider}}.csv
{%- endif %}
