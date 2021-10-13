{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
- registry.database
- docker_apps

{% set entry = pillar.docker_apps.registry %}
{% set directory = docker_apps_directory + entry.target %}

cd {{ directory }}; /usr/local/bin/docker-compose up -d cbom:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/env
