# At present, this file only needs to be included if deploying the reporting UI.

include:
  - docker_apps

{% set entry = pillar.docker_apps.pelican_frontend %}

# Manage the service account at https://console.cloud.google.com/apis/credentials?project=pelican-289615
{{ entry.host_dir }}/credentials.json:
  file.managed:
    - source: salt://pelican/frontend/files/credentials.json
    - template: jinja
    - context: {{ entry.google|yaml }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
