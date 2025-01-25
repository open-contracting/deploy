{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  # django.conf.include
  - apache.modules.headers # RequestHeader
  - apache.modules.proxy_http # ProxyPass
  - docker_apps

{% set entry = pillar.docker_apps.digitalbuying %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'digitalbuying') }}

# https://guide.wagtail.org/en-latest/concepts/scheduled-publishing/
# https://docs.wagtail.org/en/stable/reference/management_commands.html#publish-scheduled
cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name digitalbuying-cron -e LOG_LEVEL=WARNING cron python manage.py publish_scheduled_pages:
  cron.present:
    - identifier: DIGITALBUYINGGUIDE_PUBLISH_SCHEDULED_PAGES
    - user: {{ pillar.docker.user }}
    - minute: random
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env
