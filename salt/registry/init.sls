{% from 'lib.sls' import create_user %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
- registry.database
- docker
- docker_apps

{{ create_user(pillar.docker.user) }}

cd {{ docker_apps_directory }}{{ pillar.docker_apps.registry.target }}; docker-compose up -d cbom:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'
