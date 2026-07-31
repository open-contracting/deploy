#!/bin/sh
# shellcheck disable=SC1083

set -eu

logdir="{{ userdir }}/logs/{{ crawl.spider }}/$(date +%Y)"
script="{{ script }}"

mkdir -p "$logdir"

cd {{ directory }}

env http_proxy={{ pillar.tinyproxy.url }} https_proxy={{ pillar.tinyproxy.url }} no_proxy=localhost,sentry.io,standard.open-contracting.org .ve/bin/scrapy crawl \
    {{ crawl.spider }}{% if 'spider_arguments' in crawl %} {{ crawl.spider_arguments }}{% endif %} \
    -a crawl_time={{ crawl.crawl_time }}T00:00:00 \
    -s FILES_STORE={{ userdir }}/data \
    -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect \
    {% if 'settings' in crawl %}{% for key, value in crawl.settings | items %}-s {{ key }}={{ value }} \
    {% endfor %}{% endif %}-s SENTRY_DSN={{ SENTRY_DSN }} \
    --logfile="$logdir/$(date +%F).log"

if [ -n "$script" ]; then
    "$script"
fi
