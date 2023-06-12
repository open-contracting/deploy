{% from 'lib.sls' import create_user %}

{% for user, authorized_keys in pillar.users.items() %}
{{ create_user(user, authorized_keys=authorized_keys) }}

/home/{{ user }}/.pgpass:
  file.managed:
    - contents: |
        localhost:5432:kingfisher_process:{{ user }}:{{ pillar.postgres.users[user].password }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 400
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

useful commands for data support:
  pkg.installed:
    - pkgs:
      - jq
      - unrar

pip:
  pkg.installed:
    - name: python3-pip
  pip.installed:
    - name: pip
    - upgrade: True
    - require:
      - pkg: pip

useful packages for data support:
  pip.installed:
    - names:
      - flattentool
      - ocdskit
    - upgrade: True
    - require:
      - pip: pip

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
      - postgres_database: kingfisher_process

# This file can be updated with:
#
#   curl -O https://standard.open-contracting.org/schema/1__1__5/release-schema.json
#   ocdskit mapping-sheet --infer-required release-schema.json > mapping-sheet-orig.csv
#   awk -F, '!a[$2]++' mapping-sheet-orig.csv > mapping-sheet-uniq.csv
#   awk 'NR==1 {print "version,extension," $0}; NR>1 {print "1.1,core," $0}' mapping-sheet-uniq.csv > mapping-sheet.csv
/opt/mapping-sheet.csv:
  file.managed:
    - source: salt://kingfisher/files/mapping-sheet.csv

/opt/mapping-sheet.sql:
  file.managed:
    - source: salt://kingfisher/files/mapping-sheet.sql
    - template: jinja
    - context:
        path: /opt/mapping-sheet.csv

create reference.mapping_sheets table:
  cmd.run:
    - name: psql -f /opt/mapping-sheet.sql kingfisher_process
    - runas: postgres
    - onchanges:
      - file: /opt/mapping-sheet.csv
      - file: /opt/mapping-sheet.sql
    - require:
      - postgres_group: reference
      - postgres_schema: reference_sql_schema
