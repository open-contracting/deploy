{% from 'lib.sls' import create_user, set_cron_env %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user, authorized_keys=salt['pillar.get']('ssh:incremental', [])) }}

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
    - contents: |
        localhost:5432:kingfisher_collect:kingfisher_collect:{{ pillar.postgres.users.kingfisher_collect.password }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - user: {{ entry.user }}_user_exists

{%
  set crawls = [
    {
      'identifier': 'CHILE',
      'spider': 'chile_compra_api_records',
      'start_date': '2021-12-03',
      'day': 1,
      'options': '-a compile_releases=true',
    },
    {
      'identifier': 'DOMINICAN_REPUBLIC',
      'spider': 'dominican_republic_api',
      'start_date': '2018-01-01',
      'options': '-a compile_releases=true',
    },
    {
      'identifier': 'ECUADOR',
      'spider': 'ecuador_sercop_bulk',
      'start_date': '2015-01-01',
    },
    {
      'identifier': 'MOLDOVA',
      'spider': 'moldova',
      'start_date': '2021-06-11',
    },
  ]
%}

{{ set_cron_env(entry.user, "MAILTO", "sysadmin@open-contracting.org") }}

# Note that "%" has special significance in cron, so it must be escaped.
{% for crawl in crawls %}
cd {{ directory }}; . .ve/bin/activate; scrapy crawl {{ crawl.spider }}{% if 'options' in crawl %} {{ crawl.options }}{% endif %} -a crawl_time={{ crawl.start_date }}T00:00:00 --logfile={{ userdir }}/logs/{{ crawl.spider }}-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }}
    - user: {{ entry.user }}
    {% if 'day' in crawl %}
    - daymonth: {{ crawl.day }}
    {% endif %}
    - hour: 0
    - minute: 15
    - require:
      - virtualenv: {{ directory }}/.ve
      - file: {{ userdir }}/data
      - file: {{ userdir }}/logs
{% endfor %}
