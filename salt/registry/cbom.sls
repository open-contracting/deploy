{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
- docker
- docker_apps


cd {{ docker_apps_directory }}{{ pillar.docker_apps.registry.target }}; docker-compose up -d cbom:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'
