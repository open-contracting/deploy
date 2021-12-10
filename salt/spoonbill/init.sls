include:
- docker_apps

{% set directory = '/data/spoonbill' %}

{{ directory }}:
  file.directory:
    - names:
      - {{ directory }}/tmp
      - {{ directory }}/media
    - makedirs: True
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - require:
      - user: {{ pillar.docker.user }}_user_exists
