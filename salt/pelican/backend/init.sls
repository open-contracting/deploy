{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.pelican_backend %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'pelican.backend') }}

/home/{{ pillar.docker.user }}/.pgpass:
  file.managed:
    - contents: |
        localhost:5432:pelican_backend:pelican_backend:{{ pillar.postgres.users.pelican_backend.password }}
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - mode: 400
    - require:
      - user: {{ pillar.docker.user }}_user_exists

cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm -e LOG_LEVEL=WARNING cron python manage.py update-exchange-rates:
  cron.present:
    - identifier: PELICAN_BACKEND_UPDATE_EXCHANGE_RATES
    - user: {{ pillar.docker.user }}
    - hour: '*/12'
    - minute: random
    - require:
      - file: {{ directory }}/docker-compose.yaml
      - file: {{ directory }}/.env

btree_gin:
  postgres_extension.present:
    - if_not_exists: True
    - maintenance_db: pelican_backend
    - require:
      - postgres_database: pelican_backend_sql_database

{%
  for basename, source_hash in [
    ('001_base', '2b195c9983988080c5563ae0af4f722cfe51ece9882fe0e0ade5c324bd2eefab'),
    ('002_constraints', 'f298f0b8cb20d47f390b480d44d12c097e83b177dde56234dcbebc6ad3dcf229'),
  ]
%}
{{ directory }}/files/{{ basename }}.sql:
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
    - name: psql -U pelican_backend -h localhost -f {{ directory }}/files/{{ basename }}.sql pelican_backend
    - runas: {{ pillar.docker.user }}
    - require:
      - postgres_database: pelican_backend_sql_database
      - file: /home/{{ pillar.docker.user }}/.pgpass
    - onchanges:
      - file: {{ directory }}/files/{{ basename }}.sql
{% endfor %}
