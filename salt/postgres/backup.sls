{% from 'lib.sls' import set_config %}

{% if salt['pillar.get']('postgres:backup:type') == 'script' %}
include:
  - aws

{{ set_config('aws-settings.local', 'S3_DATABASE_BACKUP_BUCKET', pillar.postgres.backup.location) }}

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

set BACKUP_DATABASES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: BACKUP_DATABASES
    - value: '( "{{ pillar.postgres.backup.databases|join('" "') }}" )'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
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
    - source: salt://postgres/files/pgbackrest/{{ pillar.postgres.backup.configuration }}.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - makedirs: True
    - require:
      - pkg: postgresql

{% if salt['pillar.get']('postgres:backup:cron') %}
/etc/cron.d/postgres_backups:
  file.managed:
    - contents: |
        MAILTO=root
        # Daily incremental backup
        15 05 * * 0-2,4-6 postgres pgbackrest backup --stanza={{ pillar.postgres.backup.stanza }}
        # Weekly full backup
        15 05 * * 3 postgres pgbackrest backup --stanza={{ pillar.postgres.backup.stanza }} --type=full 2>&1 | grep -v "unable to remove file.*We encountered an internal error\. Please try again\.\|expire command encountered 1 error.s., check the log file for details"
    - require:
      - pkg: pgbackrest
{% endif %}
{% endif %}
