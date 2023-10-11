{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # credere.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.credere_backend %}
{% set directory = docker_apps_directory + entry.target %}

{%
  set crawls = [
    {
      'identifier': 'FETCH_AWARDS',
      'command': 'fetch-awards',
      # 9AM in Colombia (no daylight saving time).
      'hour': 14
    },
    {
      'identifier': 'REMIND_MSME',
      'command': 'send-reminders',
      # 10AM in Colombia (no daylight saving time).
      'hour': 15
    },
    {
      'identifier': 'REMIND_FI',
      'command': 'sla-overdue-applications',
      # 08AM in Colombia (no daylight saving time).
      'hour': 13
    },
    {
      'identifier': 'LAPSE_APPLICATIONS',
      'command': 'update-applications-to-lapsed',
      'hour': 1
    },
    {
      'identifier': 'REMOVE_LAPSED_APPLICATIONS',
      'command': 'remove-dated-application-data',
      'hour': 2
    },
    {
      'identifier': 'UPDATE_STATISTICS',
      'command': 'update-statistics',
      'hour': 3
    },
  ]
%}

{{ set_cron_env(pillar.docker.user, "MAILTO", "sysadmin@open-contracting.org") }}

{% for crawl in crawls %}
# docker compose does not have a quiet option: https://github.com/docker/compose/issues/6026
cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm cron python -m app.commands {{ crawl.command }}:
  cron.present:
    - identifier: CREDERE_{{ crawl.identifier }}
    - user: {{ pillar.docker.user }}
    - hour: {{ crawl.hour }}
    - minute: 0
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
{% endfor %}
