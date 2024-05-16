{% from 'lib.sls' import create_user, set_cron_env %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_collect %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set sqldir = userdir + '/bi/sql' %}
{% set settingsdir = userdir + '/bi/settings' %}
{% set scratchdir = userdir + '/bi/scratch' %}

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

{{ set_cron_env(entry.user, 'MAILTO', 'sysadmin@open-contracting.org', 'kingfisher.collect.incremental') }}

{% if entry.crawls|selectattr('powerbi', 'defined')|first|default %}
rustup:
  cmd.run:
    - name: "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly"
    - runas: {{ entry.user }}
    - creates: /home/{{ entry.user }}/.cargo/bin/rustup

{{ userdir }}/cardinal-rs:
  git.latest:
    - name: https://github.com/open-contracting/cardinal-rs
    - user: {{ entry.user }}
    - force_fetch: True
    - force_reset: True
    - branch: main
    - rev: main
    - target: {{ userdir }}/cardinal-rs
    - require:
      - pkg: git
      - user: {{ entry.user }}_user_exists

cardinal:
  cmd.run:
    - name: cargo install --path {{ userdir }}/cardinal-rs
    - runas: {{ entry.user }}
    - onchanges:
      - git: {{ userdir }}/cardinal-rs

{{ scratchdir }}:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/bin/manage.py:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/cardinal-rs/main/manage.py
    # curl -sSf https://raw.githubusercontent.com/open-contracting/cardinal-rs/main/manage.py | shasum -a 256
    - source_hash: 05c439e6c12cc84d64c08a1ac1484aac4fdaf3255a7691d0c2cc6790986c8fe7
    - makedirs: True
    - mode: 755
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

# curl -sSf https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/codelist.csv  | shasum -a 256
# curl -sSf https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/indicator.csv  | shasum -a 256
# curl -sSf https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/cpc.csv  | shasum -a 256
# curl -sSf https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/unspsc.csv  | shasum -a 256
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
    - name: psql -U kingfisher_collect -h localhost -f {{ sqldir }}/{{ basename }}.sql kingfisher_collect
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
    - name: psql -U kingfisher_collect -h localhost -f {{ sqldir }}/excluded_supplier.sql kingfisher_collect
    - runas: {{ entry.user }}
    - require:
      - postgres_user: kingfisher_collect_sql_user
      - postgres_database: kingfisher_collect_sql_database
    - onchanges:
      - file: {{ sqldir }}/excluded_supplier.sql
      - file: {{ userdir }}/.pgpass
{% endif %}

{% for crawl in entry.crawls %}
{{ userdir }}/bin/{{ crawl.spider }}.sh:
  file.managed:
    - source: salt://kingfisher/collect/files/bi/cron.sh
    - template: jinja
    - context:
        SENTRY_DSN: {{ pillar.kingfisher_collect.env.SENTRY_DSN }}
        directory: {{ directory }}
        userdir: {{ userdir }}
        crawl: {{ crawl }}
        # Power BI
        settingsdir: {{ settingsdir }}
        scratchdir: {{ scratchdir }}
    - makedirs: True
    - mode: 755
    - require:
      - user: {{ entry.user }}_user_exists

add OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }} cron job in {{ entry.user }} crontab:
  cron.present:
    - identifier: OCDS_KINGFISHER_COLLECT_{{ crawl.identifier }}
    - name: {{ userdir }}/bin/{{ crawl.spider }}.sh
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
{{ settingsdir }}/{{ crawl.spider }}.ini:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/bi.open-contracting.org/main/powerbi/{{ crawl.spider }}.ini
    - source_hash: {{ crawl.cardinal_ini_source_hash }}
    - makedirs: True
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

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
{% endif %}
{% endfor %}
