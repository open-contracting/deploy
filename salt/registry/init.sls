{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # django.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.registry %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'registry') }}

useful commands for registry maintenance:
  pkg.installed:
    - pkgs:
      - jq
      - ripgrep

cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name data-registry-cron -e LOG_LEVEL=WARNING cron python manage.py manageprocess:
  cron.present:
    - identifier: DATA_REGISTRY_CBOM
    - user: {{ pillar.docker.user }}
    - minute: '*/5'
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env

{{ pillar.exporter_host_dir }}:
  file.directory:
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
