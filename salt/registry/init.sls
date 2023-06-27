{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - apache.modules.headers # RequestHeader in registry.conf.include
  - docker_apps

{% set entry = pillar.docker_apps.registry %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, "MAILTO", "sysadmin@open-contracting.org", "registry") }}

# docker-compose does not have a quiet option: https://github.com/docker/compose/issues/6026
cd {{ directory }}; /usr/local/bin/docker-compose run --rm cron python manage.py manageprocess 2> /dev/null:
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
