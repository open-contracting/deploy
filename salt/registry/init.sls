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

{{ entry.exporter_host_dir }}:
  file.directory:
    - makedirs: True
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - require:
      - user: {{ pillar.docker.user }}_user_exists

{{ pillar.kingfisher_collect.env.FILES_STORE }}:
  file.directory:
    - makedirs: True
    - mode: 2775
    - user: {{ pillar.kingfisher_collect.user }}
    - group: {{ pillar.kingfisher_collect.group }}
    - require:
      - user: {{ pillar.kingfisher_collect.user }}_user_exists
      - user: {{ pillar.kingfisher_collect.group }}_user_exists

/data/storage/spoonbill:
  file.directory:
    - names:
      - {{ directory }}/tmp
      - {{ directory }}/media
    - makedirs: True
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - require:
      - user: {{ pillar.docker.user }}_user_exists
