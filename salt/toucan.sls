toucan-deps:
  pkg.installed:
    - pkgs:
      - libyajl-dev # OCDS Kit performance

include:
  - django

/home/{{ pillar.user }}/{{ pillar.name }}/googleapi_credentials.json:
  file.managed:
    - source: salt://lib/googleapi_credentials.json
    - template: jinja
    - user: {{ pillar.user }}
    - group: {{ pillar.user }}
    - mode: 600

find /home/ocdskit-web/ocdskit-web/media -mindepth 2 -mtime +1 -delete:
  cron.present:
    - identifier: OCDS_TOUCAN_CLEAR_MEDIA_1
    - user: {{ pillar.user }}
    - minute: 0
    - hour: 0

find /home/ocdskit-web/ocdskit-web/media -mindepth 1 -type d -empty -delete:
  cron.present:
    - identifier: OCDS_TOUCAN_CLEAR_MEDIA_2
    - user: {{ pillar.user }}
    - minute: 0
    - hour: 0
