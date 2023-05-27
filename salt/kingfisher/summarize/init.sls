{% from 'lib.sls' import create_user, set_cron_env %}

include:
  - python.psycopg2
  - python_apps

{% set entry = pillar.python_apps.kingfisher_summarize %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user) }}

{{ directory }}/.env:
  file.managed:
    - source: salt://kingfisher/summarize/files/.env
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 444
    - require:
      - git: {{ entry.git.url }}

{{ userdir }}/.pgpass:
  file.managed:
    - contents: |
      localhost:5432:kingfisher_process:kingfisher_summarize:{{ pillar.postgres.users.kingfisher_summarize.password }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 400
    - require:
      - user: {{ entry.user }}_user_exists

# "The database user must have the CREATE privilege on the database used by Kingfisher Process."
# https://kingfisher-summarize.readthedocs.io/en/latest/get-started.html#database
grant kingfisher_summarize database privileges:
  postgres_privileges.present:
    - name: kingfisher_summarize
    - privileges:
      - CREATE
    - object_type: database
    - object_name: kingfisher_process
    - maintenance_db: kingfisher_process
    - require:
      - postgres_user: kingfisher_summarize_sql_user
      - postgres_database: kingfisher_process

{{ set_cron_env(entry.user, "MAILTO", "sysadmin@open-contracting.org") }}

# Delete schema whose selected collections no longer exist.
cd {{ directory }}; . .ve/bin/activate; python manage.py -q dev stale | xargs -I{} python manage.py --quiet remove {}:
  cron.present:
    - identifier: KINGFISHER_SUMMARIZE_ORPHAN_SCHEMA
    - user: {{ entry.user }}
    - daymonth: 1
    - hour: 3
    - minute: 45
    - require:
      - virtualenv: {{ directory }}/.ve
