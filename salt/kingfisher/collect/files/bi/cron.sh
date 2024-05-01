#!/usr/bin/env bash
# shellcheck disable=SC1083

set -euo pipefail

cd {{ directory }}

.ve/bin/scrapy crawl {{ crawl.spider }}{% if 'options' in crawl %} {{ crawl.options }}{% endif %} \
    -a crawl_time={{ crawl.start_date }}T00:00:00 \
    -s FILES_STORE={{ userdir }}/data \
    -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect \
    --logfile="{{ userdir }}/logs/{{ crawl.spider }}-$(date +%F).log"
