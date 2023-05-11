{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
- docker_apps

{% set entry = pillar.docker_apps.pelican_backend %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, "MAILTO", "sysadmin@open-contracting.org") }}

# docker-compose does not have a quiet option: https://github.com/docker/compose/issues/6026
cd {{ directory }}; /usr/local/bin/docker-compose run --rm extract python manage.py update-exchange-rates 2> /dev/null:
  cron.present:
    - identifier: PELICAN_BACKEND_UPDATE_EXCHANGE_RATES
    - user: {{ pillar.docker.user }}
    - hour: '*/12'
    - minute: random
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env

{%
  for basename, source_hash in [
    ('001_base', '2b195c9983988080c5563ae0af4f722cfe51ece9882fe0e0ade5c324bd2eefab'),
    ('002_constraints', 'f298f0b8cb20d47f390b480d44d12c097e83b177dde56234dcbebc6ad3dcf229'),
  ]
%}
/opt/pelican-backend/{{ basename }}.sql:
  file.managed:
    - source: https://raw.githubusercontent.com/open-contracting/pelican-backend/main/pelican/migrations/{{ basename }}.sql
    - source_hash: {{ source_hash }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

run pelican migration {{ basename }}:
  cmd.run:
    - name: psql -c 'SET ROLE pelican_backend' -f /opt/pelican-backend/{{ basename }}.sql pelican_backend
    - runas: postgres
    - onchanges:
      - file: /opt/pelican-backend/{{ basename }}.sql
    - require:
      - postgres_database: pelican_backend
{% endfor %}

/opt/pelican-backend/exchange_rates.csv:
  file.managed:
    - source: salt://private/files/exchange_rates.csv
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists

# After the migrations run, manually populate the exchange_rates table.
#
# psql -c 'SET ROLE pelican_backend' -c "\copy exchange_rates (valid_on, rates, created, modified) from '/opt/pelican-backend/exchange_rates.csv' delimiter ',' csv header;" pelican_backend
#
# This allows us to update exchange_rates.csv for new servers, without interfering with existing servers.
