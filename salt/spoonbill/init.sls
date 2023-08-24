include:
  - docker_apps

{% set entry = pillar.docker_apps.spoonbill %}

{{ entry.host_dir }}:
  file.directory:
    - names:
      - {{ entry.host_dir }}/tmp
      - {{ entry.host_dir }}/media
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
