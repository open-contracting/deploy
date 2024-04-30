{% from 'lib.sls' import create_user, set_cron_env %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set sqldir = userdir + '/bi/sql' %}

{{ create_user(entry.user, authorized_keys=salt['pillar.get']('ssh:incremental', [])) }}

# Allow postgres to access, to run SQL files.
allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ entry.user }}_user_exists

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

{{ set_cron_env(entry.user, 'MAILTO', 'sysadmin@open-contracting.org') }}

{% if entry.crawls|selectattr('powerbi', 'defined')|first|default %}
{% for basename, source_hash in [
  ('codelist', 'c4387a4b1a600843413525f41bcdd0f63e074f060c4d053035cba03984a26de4'),
  ('indicator', '281065a1709ebde2ce2cad369ac53c7238aae51c860cb630e981d4a3eea5cf1b'),
  ('cpc', '1a1c8d833830326dd6dcd87d236134a32c719a1ad2d8b5ff3206d090076ae3fa'),
  ('unspsc', '3040466f858d4dd72ecb32c5a6f669ccd9ef62dd3f58f5d1e1b42c61da7e4aee'),
] %}
{{ sqldir }}/{{ basename }}.csv:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/{{ basename }}.csv
    - source_hash: {{ source_hash }}
    - makedirs: True
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ sqldir }}/{{ basename }}.sql:
  file.managed:
    - source: salt://kingfisher/collect/files/bi/{{ basename }}.sql
    - template: jinja
    - context:
        path: {{ sqldir }}/{{ basename }}.csv
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists

run {{ sqldir }}/{{ basename }}.sql:
  cmd.run:
    - name: psql -f {{ sqldir }}/{{ basename }}.sql kingfisher_collect
    - runas: {{ entry.user }}
    - require:
      - postgres_user: kingfisher_collect_sql_user
      - postgres_database: kingfisher_collect_sql_database
    - onchanges:
      - file: {{ sqldir }}/{{ basename }}.csv
      - file: {{ sqldir }}/{{ basename }}.sql
      - file: {{ userdir }}/.pgpass
{% endfor %}

{{ sqldir }}/excluded_supplier.sql:
  file.managed:
    - source: salt://kingfisher/collect/files/bi/excluded_supplier.sql
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists

run {{ sqldir }}/excluded_supplier.sql:
  cmd.run:
    - name: psql -f {{ sqldir }}/excluded_supplier.sql kingfisher_collect
    - runas: {{ entry.user }}
    - require:
      - postgres_user: kingfisher_collect_sql_user
      - postgres_database: kingfisher_collect_sql_database
    - onchanges:
      - file: {{ sqldir }}/excluded_supplier.sql
      - file: {{ userdir }}/.pgpass
{% endif %}

# Note that "%" has special significance in cron, so it must be escaped.
{% for crawl in entry.crawls %}

cd {{ directory }}; .ve/bin/scrapy crawl {{ crawl.spider }}{% if 'options' in crawl %} {{ crawl.options }}{% endif %} -a crawl_time={{ crawl.start_date }}T00:00:00 --logfile={{ userdir }}/logs/{{ crawl.spider }}-$(date +\%F).log -s DATABASE_URL=postgresql://kingfisher_collect@localhost:5432/kingfisher_collect -s FILES_STORE={{ userdir }}/data:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }}
    - user: {{ entry.user }}
    {% if 'day' in crawl %}
    - daymonth: '{{ crawl.day }}'
    {% endif %}
    - hour: 0
    - minute: 15
    - require:
      - virtualenv: {{ directory }}/.ve
      - file: {{ userdir }}/data
      - file: {{ userdir }}/logs

{% if crawl.get('powerbi') %}
{{ sqldir }}/{{ crawl.spider }}_result.sql:
  file.managed:
    - source: salt://kingfisher/collect/files/bi/result.sql
    - template: jinja
    - context:
        spider: {{ crawl.spider }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists

run {{ sqldir }}/{{ crawl.spider }}_result.sql:
  cmd.run:
    - name: psql -f {{ sqldir }}/{{ crawl.spider }}_result.sql kingfisher_collect
    - runas: {{ entry.user }}
    - require:
      - postgres_user: kingfisher_collect_sql_user
      - postgres_database: kingfisher_collect_sql_database
    - onchanges:
      - file: {{ sqldir }}/{{ crawl.spider }}_result.sql
      - file: {{ userdir }}/.pgpass
{% endif %}
{% endfor %}
