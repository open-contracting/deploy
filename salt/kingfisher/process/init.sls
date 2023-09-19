# At present, this file only needs to be included for data support. It doesn't need to be used on, for example, the data registry.
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.kingfisher_process %}
{% set directory = docker_apps_directory + entry.target %}

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
    - name: psql -f {{ directory }}/files/mapping-sheet.sql kingfisher_process
    - runas: postgres
    - require:
      - postgres_group: reference_sql_group
      - postgres_schema: reference_sql_schema
    - onchanges:
      - file: {{ directory }}/files/mapping-sheet.csv
      - file: {{ directory }}/files/mapping-sheet.sql

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

{% for command in ['addfiles', 'closecollection', 'collectionstatus', 'deletecollection', 'load'] %}
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
