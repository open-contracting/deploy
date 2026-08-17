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
    ('001_base', '957af7491d756f4fdcd59166632e2984da0aa0e7f18f75beed2e9013c8144caa'),
    ('002_constraints', '3cccc657b021f6a9acf530859a6a54a1771a53640f653a10f172afd9160f4543'),
    ('20260815031218354_not_null', '6e0d47733b40089fa28c194e11977bc2343729a941f93d24db96e57977342b3a'),
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
