{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.spoonbill %}
{% set directory = docker_apps_directory + entry.target %}

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

{{ directory }}/traefik.toml:
  file.managed:
    - source: salt://spoonbill/files/traefik.toml
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
