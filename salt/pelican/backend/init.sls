{% from 'lib.sls' import set_cron_env %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.pelican_backend %}
{% set directory = docker_apps_directory + entry.target %}

{{ set_cron_env(pillar.docker.user, 'MAILTO', 'sysadmin@open-contracting.org', 'pelican.backend') }}

pgpass-pelican_backend:
  file.replace:
    - name: /home/{{ pillar.docker.user }}/.pgpass
    - pattern: '^localhost:5432:pelican_backend:pelican_backend:.+$'
    - repl: 'localhost:5432:pelican_backend:pelican_backend:{{ pillar.postgres.users.pelican_backend.password }}'
    - append_if_not_found: True
    - backup: False
    - require:
      - user: {{ pillar.docker.user }}_user_exists

cd {{ directory }}; /usr/bin/docker compose --progress=quiet run --rm --name pelican-backend-cron -e LOG_LEVEL=WARNING cron python manage.py update-exchange-rates:
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

# To update a hash, run, for example:
#
# curl -sSf https://raw.githubusercontent.com/open-contracting/pelican-backend/main/pelican/migrations/001_base.sql | shasum -a 256
{%
  for basename, source_hash in [
    ('001_base', 'fc0089de1a4ad4bd3b36b37734982d9d323852fada92ca7c1ecede9f2e43b90e'),
    ('002_constraints', 'b3293a1f7f1202670f15b60905188da546e3b12f738e078535ccbd10e6d7e3c4'),
    ('20260815031218354_not_null', '12f25d91f2cce7dcd1f5573dde5f708805d9d0b932c7b5daa59bbabc9a7936b0'),
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
    - name: psql -v ON_ERROR_STOP=1 -U pelican_backend -h localhost -f {{ directory }}/files/{{ basename }}.sql pelican_backend && touch {{ directory }}/files/{{ basename }}.lock
    - runas: {{ pillar.docker.user }}
    - creates: {{ directory }}/files/{{ basename }}.lock
    - require:
      - postgres_user: pelican_backend_sql_user
      - postgres_database: pelican_backend_sql_database
      - file: pgpass-pelican_backend
      - file: {{ directory }}/files/{{ basename }}.sql
{% endfor %}
