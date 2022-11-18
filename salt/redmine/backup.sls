{% from 'lib.sls' import set_config %}
{% from 'redmine/init.sls' import user %}

include:
  - aws

{{ set_config("aws-settings.local", "S3FILEBACKUPBUCKET", pillar.redmine.backup.location) }}
{{ set_config("aws-settings.local", "FOLDER2S3BACKUPSRC", "( \"/home/"+user+"/public_html\" )") }}

/home/sysadmin-tools/bin/site-backup-to-s3.sh:
  file.managed:
    - source: salt://files/site-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/redmine_backup:
  file.managed:
    - contents: |
        MAILTO=root
        15 04 * * * root /home/sysadmin-tools/bin/site-backup-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/site-backup-to-s3.sh
