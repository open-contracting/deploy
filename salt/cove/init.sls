{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # cove.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'cove') }}

useful commands for CoVE analysis:
  pkg.installed:
    - pkgs:
      - jq
      - ripgrep

{% for name, entry in pillar.docker_apps|items %}
{% set directory = docker_apps_directory + entry.target %}

cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name {{ entry.image }}-cron -e LOG_LEVEL=WARNING cron python manage.py expire_files:
  cron.present:
    - identifier: {{ name|upper }}_EXPIRE_FILES
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
{% endfor %}
