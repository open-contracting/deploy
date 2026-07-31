#!/bin/sh
# shellcheck disable=SC1083

set -eu

spider="{{ crawl.spider }}"
userdir="{{ userdir }}"
settingsdir="{{ settingsdir }}"
scratchdir="{{ scratchdir }}"

psql -U kingfisher_collect -h localhost -t -c "SELECT data FROM $spider" -o "$scratchdir/$spider.jsonl"

"$userdir"/.cargo/bin/ocdscardinal prepare \
    -s "$settingsdir/$spider.ini" \
    -o "$scratchdir/$spider.out.jsonl" \
    -e "$scratchdir/$spider.err.csv" \
    "$scratchdir/$spider.jsonl"

if [ -s "$scratchdir/$spider.err.csv" ]; then
    echo "$scratchdir/$spider.jsonl contains new errors"
    exit 1
fi

"$userdir"/.cargo/bin/ocdscardinal indicators \
    -s "$settingsdir/$spider.ini" \
    --map \
    "$scratchdir/$spider.out.jsonl" \
    > "$scratchdir/$spider.json"

# This appends to the CSV file, to keep flags consistent over time. Delete it manually if results are incorrect.
"$userdir"/bin/manage.py json-to-csv -q "$scratchdir/$spider.json" "$scratchdir/$spider.csv"

psql -U kingfisher_collect -h localhost -q \
    -c "BEGIN" \
    -c "DROP TABLE IF EXISTS ${spider}_clean" \
    -c "CREATE TABLE ${spider}_clean (data jsonb)" \
    -c "\copy ${spider}_clean (data) FROM stdin CSV QUOTE e'\x01' DELIMITER e'\x02'" \
    -c "CREATE INDEX idx_${spider}_clean ON ${spider}_clean (cast(data->>'date' as text))" \
    -c "END" \
    < "$scratchdir/$spider.out.jsonl"

psql -U kingfisher_collect -h localhost -q \
    -c "BEGIN" \
    -c "DROP TABLE IF EXISTS ${spider}_result" \
    -f "$userdir/bi/sql/${spider}_result.sql" \
    -c "\copy ${spider}_result (ocid, subject, code, result, buyer_id, procuring_entity_id, tenderer_id, created_at) FROM stdin DELIMITER ',' CSV HEADER" \
    -c "END" \
    < "$scratchdir/$spider.csv"
