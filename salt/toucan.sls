toucan-deps:
  pkg.installed:
    - pkgs:
      - libyajl-dev # OCDS Kit performance

include:
  - django

root_toucan:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_toucan

/home/{{ pillar.user }}/{{ pillar.name }}/googleapi_credentials.json:
  file.managed:
    - user: {{ pillar.user }}
    - group: {{ pillar.user }}
    - mode: 600
    - source: salt://private/toucan/googleapi_credentials.json

{% from 'lib.sls' import apache %}

find /home/ocdskit-web/ocdskit-web/media -mindepth 2 -mtime +1 -exec rm {} \;:
  cron.present:
    - identifier: OCDS_TOUCAN_CLEAR_MEDIA_1
    - user: {{ pillar.user }}
    - minute: 0
    - hour: 0

find /home/ocdskit-web/ocdskit-web/media -mindepth 1 -type d -print | xargs rmdir 2>/dev/null:
  cron.present:
    - identifier: OCDS_TOUCAN_CLEAR_MEDIA_2
    - user: {{ pillar.user }}
    - minute: 0
    - hour: 0
