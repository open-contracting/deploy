{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # cove.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.cove %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'cove') }}

cd {{ directory }};  /usr/bin/docker compose --progress=quiet run --rm --name cove-cron -e LOG_LEVEL=WARNING cron python manage.py expire_files:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: {{ pillar.docker.user }}
    - hour: 0
    - minute: random
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env

{{ entry.host_dir }}:
  file.directory:
    - names:
      - {{ entry.host_dir }}/db
      - {{ entry.host_dir }}/media
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

useful commands for CoVE analysis:
  pkg.installed:
    - pkgs:
      - jq
      - ripgrep
