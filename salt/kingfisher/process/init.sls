# At present, this file only needs to be included for data support. It doesn't need to be used on, for example, the data registry.
{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.kingfisher_process %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'kinfisher.process') }}

# https://github.com/open-contracting/deploy/issues/117 for analysts to create pivot tables.
# https://github.com/open-contracting/deploy/issues/237 for analysts to match similar strings.
create kingfisher process extensions:
  postgres_extension.present:
    - names:
      - tablefunc
      - fuzzystrmatch
      - pg_trgm
    - if_not_exists: True
    - maintenance_db: kingfisher_process
    - require:
      - postgres_database: kingfisher_process_sql_database

# Reference schema

# This file can be updated with:
#
#   curl -O https://standard.open-contracting.org/schema/1__1__5/release-schema.json
#   ocdskit mapping-sheet --infer-required release-schema.json > mapping-sheet-orig.csv
#   awk -F, '!a[$2]++' mapping-sheet-orig.csv > mapping-sheet-uniq.csv
#   awk 'NR==1 {print "version,extension," $0}; NR>1 {print "1.1,core," $0}' mapping-sheet-uniq.csv > mapping-sheet.csv
{{ directory }}/files/mapping-sheet.csv:
  file.managed:
    - source: salt://kingfisher/files/mapping-sheet.csv
    - makedirs: True

{{ directory }}/files/mapping-sheet.sql:
  file.managed:
    - source: salt://kingfisher/files/mapping-sheet.sql
    - template: jinja
    - context:
        path: {{ directory }}/files/mapping-sheet.csv
    - makedirs: True

create reference.mapping_sheets table:
  cmd.run:
    - name: psql -v ON_ERROR_STOP=1 -f {{ directory }}/files/mapping-sheet.sql kingfisher_process
    - runas: postgres
    - require:
      - postgres_group: reference_sql_group
      - postgres_schema: reference_sql_schema
    - onchanges:
      - file: {{ directory }}/files/mapping-sheet.csv
      - file: {{ directory }}/files/mapping-sheet.sql

# Cron jobs

pgpass-kingfisher_process:
  file.replace:
    - name: /home/{{ pillar.docker.user }}/.pgpass
    - pattern: '^localhost:5432:kingfisher_process:kingfisher_process:.+$'
    - repl: 'localhost:5432:kingfisher_process:kingfisher_process:{{ pillar.postgres.users.kingfisher_process.password }}'
    - append_if_not_found: True
    - backup: False
    - require:
      - user: {{ pillar.docker.user }}_user_exists

# Delete collections that ended over a year ago, while retaining one set of collections per source from over a year ago.
cd {{ directory }}; psql -U kingfisher_process -h localhost kingfisher_process -q -t -c "SELECT id FROM collection c WHERE c.deleted_at IS NULL AND c.store_end_at < date_trunc('day', NOW() - interval '1 year') AND EXISTS(SELECT FROM collection d WHERE d.source_id = c.source_id AND d.transform_type = '' AND d.id > c.id AND d.deleted_at IS NULL AND d.store_end_at < date_trunc('day', NOW() - interval '1 year')) ORDER BY id DESC" | xargs -I{} /usr/bin/docker compose --progress=quiet run --rm --name kingfisher-process-cron-stale -e LOG_LEVEL=WARNING cron python manage.py deletecollection {}:
  cron.present:
    - identifier: KINGFISHER_PROCESS_STALE_COLLECTIONS
    - user: {{ pillar.docker.user }}
    - daymonth: 1
    - hour: 3
    - minute: 0
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
      - file: pgpass-kingfisher_process

# Delete collections that never ended and started over 2 months ago.
cd {{ directory }}; psql -U kingfisher_process -h localhost kingfisher_process -q -t -c "SELECT id FROM collection WHERE deleted_at IS NULL AND store_start_at < date_trunc('day', NOW() - interval '2 month') AND store_end_at IS NULL ORDER BY id DESC" | xargs -I{} /usr/bin/docker compose --progress=quiet run --rm --name kingfisher-process-cron-unfinished -e LOG_LEVEL=WARNING cron python manage.py deletecollection {}:
  cron.present:
    - identifier: KINGFISHER_PROCESS_UNFINISHED_COLLECTIONS
    - user: {{ pillar.docker.user }}
    - daymonth: 1
    - hour: 3
    - minute: 15
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
      - file: pgpass-kingfisher_process

# Delete collections that ended over 2 months ago and have no data.
cd {{ directory }}; psql -U kingfisher_process -h localhost kingfisher_process -q -t -c "SELECT id FROM collection WHERE deleted_at IS NULL AND store_end_at < date_trunc('day', NOW() - interval '2 month') AND COALESCE(NULLIF(cached_releases_count, 0), NULLIF(cached_records_count, 0), cached_compiled_releases_count) = 0 ORDER BY id DESC" | xargs -I{} /usr/bin/docker compose --progress=quiet run --rm --name kingfisher-process-cron-empty -e LOG_LEVEL=WARNING cron python manage.py deletecollection {}:
  cron.present:
    - identifier: KINGFISHER_PROCESS_EMPTY_COLLECTIONS
    - user: {{ pillar.docker.user }}
    - daymonth: 1
    - hour: 3
    - minute: 30
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
      - file: pgpass-kingfisher_process

# Sudoers

{% for user, authorized_keys in pillar.users.items() %}
/home/{{ user }}/.pgpass:
  file.managed:
    - contents: |
        localhost:5432:kingfisher_process:{{ user }}:{{ pillar.postgres.users[user].password }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 400
    - require:
      - user: {{ user }}_user_exists

/home/{{ user }}/local-load:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

{% for command in ['addchecks', 'addfiles', 'closecollection', 'collectionstatus', 'deletecollection', 'load'] %}
/opt/kingfisher-process/{{ command }}.sh:
  file.managed:
    - source: salt://kingfisher/process/files/kingfisher-process.sh
    - template: jinja
    - context:
        directory: {{ directory }}
        command: {{ command }}
    - makedirs: True
    - mode: 755
{% endfor %}

/etc/sudoers.d/90-kingfisher-process:
  file.managed:
    - source: salt://kingfisher/process/files/sudoers
    - template: jinja
    - mode: 440
    - check_cmd: visudo -c -f
