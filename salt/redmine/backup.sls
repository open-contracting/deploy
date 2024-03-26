{% from 'lib.sls' import set_config %}
{% from 'redmine/init.sls' import userdir %}

include:
  - aws

{{ set_config('aws-settings.local', 'S3_SITE_BACKUP_BUCKET', pillar.redmine.backup.location) }}

/home/sysadmin-tools/bin/site-backup-to-s3.sh:
  file.managed:
    - source: salt://files/site-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws

/etc/cron.d/redmine_backup:
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
    - value: ( "{{ userdir }}/public_html/" )
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
