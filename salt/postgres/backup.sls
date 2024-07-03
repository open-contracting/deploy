{% from 'lib.sls' import set_config %}

include:
  - postgres
  - aws

{% if salt['pillar.get']('postgres:backup:type') == 'pgbackrest' %}
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

{% elif salt['pillar.get']('postgres:backup:type') == 'script' %}
{{ set_config('aws-settings.local', 'S3_DATABASE_BACKUP_BUCKET', pillar.postgres.backup.location ) }}
{{ set_config('aws-settings.local', 'BACKUP_DATABASES', ' '.join(pillar.postgres.backup.databases) ) }}

/home/sysadmin-tools/bin/postgres-backup-to-s3.sh:
  file.managed:
    - source: salt://postgres/files/postgres-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
{% endif %}

{% if salt['pillar.get']('postgres:backup:cron') %}
/etc/cron.d/postgres_backups:
  file.managed:
    - contents_pillar: postgres:backup:cron
{% endif %}
