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
install rustup:
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

install cardinal:
  cmd.run:
    - name: RUSTFLAGS="-Zon-broken-pipe=kill" cargo install --path {{ userdir }}/cardinal-rs
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

# https://www.postgresql.org/docs/current/predefined-roles.html
grant pg_read_server_files to kingfisher_collect:
  cmd.run:
    - name: psql -v ON_ERROR_STOP=1 -c 'GRANT pg_read_server_files to kingfisher_collect' && touch /var/lib/postgresql/grant-pg_read_server_files-kingfisher_collect.lock
    - runas: postgres
    - creates: /var/lib/postgresql/grant-pg_read_server_files-kingfisher_collect.lock
    - require:
      - postgres_user: kingfisher_collect_sql_user

{% for basename in ('codelist', 'indicator', 'cpc', 'unspsc') %}
{{ sqldir }}/{{ basename }}.csv:
  file.managed:
    - source: salt://kingfisher/collect/files/data/{{ basename }}.csv
    - makedirs: True
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ sqldir }}/{{ basename }}.sql:
  file.managed:
    - source: salt://kingfisher/collect/files/sql/{{ basename }}.sql
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
    - name: psql -v ON_ERROR_STOP=1 -U kingfisher_collect -h localhost -f {{ sqldir }}/{{ basename }}.sql kingfisher_collect
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
    - source: salt://kingfisher/collect/files/sql/excluded_supplier.sql
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists

run {{ sqldir }}/excluded_supplier.sql:
  cmd.run:
    - name: psql -v ON_ERROR_STOP=1 -U kingfisher_collect -h localhost -f {{ sqldir }}/excluded_supplier.sql kingfisher_collect
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
    - source: salt://kingfisher/collect/files/cron.sh
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
    - user: {{ entry.user }}
    - group: {{ entry.user }}
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
    - source: salt://kingfisher/collect/files/cardinal/{{ crawl.spider }}.ini
    - makedirs: True
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{{ sqldir }}/{{ crawl.spider }}_result.sql:
  file.managed:
    - source: salt://kingfisher/collect/files/sql/result.sql
    - template: jinja
    - context:
        spider: {{ crawl.spider }}
        users: {{ crawl.get('users', []) }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists
{% endif %}
{% endfor %}
