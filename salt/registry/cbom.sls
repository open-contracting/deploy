{% from 'docker_apps/init.sls' import docker_apps_directory as docker_apps_directory %}

include:
- docker
- docker_apps

{% set entry = pillar.docker_apps.registry %}
{% set directory = docker_apps_directory + entry.target %}

cd {{ directory }}; docker-compose up cbom -d:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'