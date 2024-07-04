{% from 'lib.sls' import set_config %}

{% if salt['pillar.get']('postgres:backup:type') == 'script' %}
include:
  - aws

{{ set_config('aws-settings.local', 'S3_DATABASE_BACKUP_BUCKET', pillar.postgres.backup.location) }}

set BACKUP_DATABASES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: BACKUP_DATABASES
    - value: '( "{{ pillar.postgres.backup.databases|join('" "') }}" )'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws

/home/sysadmin-tools/bin/postgres-backup-to-s3.sh:
  file.managed:
    - source: salt://postgres/files/postgres-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/postgres_backups:
  file.managed:
    - contents: |
        MAILTO=root
        45 04 * * * root /home/sysadmin-tools/bin/postgres-backup-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/postgres-backup-to-s3.sh
{% elif salt['pillar.get']('postgres:backup:type') == 'pgbackrest' %}
include:
  - postgres

# Require official PostgreSQL repo as they provide a newer version of pgbackrest.
pgbackrest:
  pkg.installed:
    - name: pgbackrest
  require:
    - sls: postgresql

/etc/pgbackrest/pgbackrest.conf:
  file.managed:
    - makedirs: True
    - user: postgres
    - group: postgres
    - source: salt://postgres/files/pgbackrest/{{ pillar.postgres.backup.configuration }}.conf
    - template: jinja

{% if salt['pillar.get']('postgres:backup:cron') %}
/etc/cron.d/postgres_backups:
  file.managed:
    - contents_pillar: postgres:backup:cron
    - require:
      - pkg: pgbackrest
{% endif %}
{% endif %}
