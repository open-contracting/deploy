{% from 'lib.sls' import set_config %}

include:
  - aws

{{ set_config('aws-settings.local', 'S3_SITE_BACKUP_BUCKET', pillar.backup.location) }}

/home/sysadmin-tools/bin/site-backup-to-s3.sh:
  file.managed:
    - source: salt://aws/files/site-backup-to-s3.sh
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

{% for directory, options in pillar.backup.directories|items %}
{% if options and options.get('exclude') %}
set BACKUP_EXCLUDE setting for {{ directory }}:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    # Must match safe_name in site-backup-to-s3.sh
    - key: BACKUP_EXCLUDE_{{ directory|regex_replace('[^a-zA-Z0-9]', '_')|regex_replace('^_|_$', '') }}
    - value: '"{{ options.exclude }}"'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
{% endif %}
{% endfor %}

set BACKUP_DIRECTORIES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: BACKUP_DIRECTORIES
    - value: '( "{{ pillar.backup.directories|join('" "') }}" )'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
