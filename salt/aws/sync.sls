{% from 'lib.sls' import set_config %}

include:
  - aws

{{ set_config('aws-settings.local', 'S3_SYNC_BUCKET', pillar.sync.location) }}

/home/sysadmin-tools/bin/sync-to-s3.sh:
  file.managed:
    - source: salt://aws/sync/files/sync-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/sync_to_s3:
  file.managed:
    - contents: |
        MAILTO=root
        15 04 * * * root /home/sysadmin-tools/bin/sync-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/sync-to-s3.sh

set SYNC_DIRECTORIES setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/aws-settings.local
    - key: SYNC_DIRECTORIES
    - value: '( "{{ pillar.sync.directories|join('" "') }}" )'
    - append_if_not_found: True
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws
