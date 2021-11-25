{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
- docker_apps

{% set entry = pillar.docker_apps.registry %}
{% set directory = docker_apps_directory + entry.target %}

# docker-compose does not have a quiet option: https://github.com/docker/compose/issues/6026
cd {{ directory }}; /usr/local/bin/docker-compose run --rm web python manage.py manageprocess 2> /dev/null:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
