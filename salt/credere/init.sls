{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # credere.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.credere_backend %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org') }}

{% for job in entry.cron|default([]) %}
cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name credere-backend-{{ job.command }} cron python -m app.commands {{ job.command }}:
  cron.present:
    - identifier: CREDERE_{{ job.identifier }}
    - user: {{ pillar.docker.user }}
    - hour: {{ job.hour }}
    - minute: 0
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
{% endfor %}
