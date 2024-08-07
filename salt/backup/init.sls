{% from 'lib.sls' import set_config %}

include:
  - aws

{{ set_config('aws-settings.local', 'S3_SITE_BACKUP_BUCKET', pillar.backup.location) }}

/home/sysadmin-tools/bin/site-backup-to-s3.sh:
  file.managed:
    - source: salt://backup/files/site-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/site_backup:
  file.managed:
    - contents: |
        MAILTO=root
        15 04 * * * root /home/sysadmin-tools/bin/site-backup-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/site-backup-to-s3.sh

set BACKUP_DIRECTORIES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: BACKUP_DIRECTORIES
    - value: '( "{{ pillar.backup.directories|join('" "') }}" )'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
