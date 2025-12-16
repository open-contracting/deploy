{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # credere.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.credere %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org') }}

{% for job in entry.cron|default([]) %}
cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name credere-{{ job.command }} cron python -m app -q {{ job.command }}:
  cron.present:
    - identifier: CREDERE_{{ job.identifier }}
    - user: {{ pillar.docker.user }}
    {% if 'hour' in job %}
    - hour: '{{ job.hour }}'
    {% endif %}
    {% if 'minute' in job %}
    - minute: '{{ job.minute }}'
    {% else %}
    - minute: 0
    {% endif %}
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
{% endfor %}
