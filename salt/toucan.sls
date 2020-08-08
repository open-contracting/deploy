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
