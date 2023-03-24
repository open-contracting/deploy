include:
- docker_apps

{% set entry = pillar.docker_apps.pelican_frontend %}

{{ entry.host_dir }}/credentials.json:
  file.managed:
    - source: salt://pelican/frontend/files/credentials.json
    - template: jinja
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
