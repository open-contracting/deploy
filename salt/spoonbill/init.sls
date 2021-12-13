include:
- docker_apps

{% set entry = pillar.docker_apps.spoonbill %}

{{ entry.base_host_dir }}:
  file.directory:
    - names:
      - {{ entry.base_host_dir }}/tmp
      - {{ entry.base_host_dir }}/media
    - makedirs: True
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - require:
      - user: {{ pillar.docker.user }}_user_exists
