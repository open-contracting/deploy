{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # proxy.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.tecolote %}
{% set directory = docker_apps_directory ~ entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'tecolote') }}

cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name tecolote-cron -e LOG_LEVEL=WARNING cron python manage.py deleteoldjobs:
  cron.present:
    - identifier: TECOLOTE_DELETE_OLD_JOBS
    - user: {{ pillar.docker.user }}
    - hour: 1
    - minute: random
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
