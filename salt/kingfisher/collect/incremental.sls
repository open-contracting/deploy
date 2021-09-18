{% from 'lib.sls' import create_user %}
{% from 'kingfisher/collect/init.sls' import directory as scrapyd_directory %}

include:
  - kingfisher.collect.database
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

kingfisher-collect-prerequisites:
  pkg.installed:
    - pkg: libpq-dev # https://www.psycopg.org/install/
    - require_in:
      - cmd: {{ directory }}-requirements
      - cmd: {{ scrapyd_directory }}-requirements

{{ userdir }}/data:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/logs:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/.pgpass:
  file.managed:
    - source: salt://postgres/files/kingfisher-collect.pgpass
    - template: jinja
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - user: {{ entry.user }}_user_exists

# To add additional spiders, change:
#
# - spider name
# - crawl time
# - logfile name
# - add `-a compile_releases=true` if needed
#
# Note that "%" has special significance in cron, so it must be escaped.

cd {{ directory }}; . .ve/bin/activate; scrapy crawl afghanistan_release_packages -a compile_releases=true -a crawl_time=2021-06-14T00:00:00 --logfile={{ userdir }}/logs/afghanistan_release_packages-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/ocdskingfishercollect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_AFGHANISTAN
    - user: {{ entry.user }}
    - hour: 0
    - minute: 15

cd {{ directory }}; . .ve/bin/activate; scrapy crawl moldova -a crawl_time=2021-06-11T00:00:00 --logfile={{ userdir }}/logs/moldova-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/ocdskingfishercollect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_MOLDOVA
    - user: {{ entry.user }}
    - hour: 0
    - minute: 15
