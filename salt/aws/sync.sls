{% from 'lib.sls' import set_config %}

include:
  - aws

{{ set_config('aws-settings.local', 'S3_SYNC_BUCKET', pillar.sync.location) }}

/home/sysadmin-tools/bin/sync-to-s3.sh:
  file.managed:
    - source: salt://aws/files/sync-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/sync_to_s3:
  file.managed:
    - contents: |
        MAILTO=root
{%- for directory, entry in pillar.sync.directories|items %}
{%- set minute = (loop.index0 * 5) % 60 %}
        {{minute}} 03,15 * * * root /home/sysadmin-tools/bin/sync-to-s3.sh {{ directory }}
        {%- for option, value in (entry or {}) | items %} --{{ option }} "{{ value }}"{% endfor %}
{%- endfor %}
    - require:
      - file: /home/sysadmin-tools/bin/sync-to-s3.sh
