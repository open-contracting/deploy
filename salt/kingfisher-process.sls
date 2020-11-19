{% from 'lib.sls' import createuser, uwsgi, apache %}

# Set up the server
# ... these bits are in ocdskingfisher.sls
# ... /etc/motd:

include:
  - apache
  - uwsgi

kingfisher-process-prerequisites:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_uwsgi
    - watch_in:
      - service: apache2
  pkg.installed:
    - pkgs:
      - python-pip
      - python3-pip
      - python3-virtualenv
      - libapache2-mod-proxy-uwsgi
      - uwsgi-plugin-python3
      - virtualenv
      - tmux
      - sqlite3
      - strace
      - redis
      - libpq-dev
      - libyajl-dev # OCDS Kit performance

{% set user = 'ocdskfp' %}
{% set userdir = '/home/' + user %}
{{ createuser(user, auth_keys_files=['kingfisher']) }}

{% set process_giturl = 'https://github.com/open-contracting/kingfisher-process.git' %}
{% set summarize_giturl = 'https://github.com/open-contracting/kingfisher-summarize.git' %}
{% set process_dir = userdir + '/ocdskingfisherprocess' %}
{% set summarize_dir = userdir + '/ocdskingfisherviews' %}

{{ process_giturl }}{{ process_dir }}:
  git.latest:
    - name: {{ process_giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ process_dir }}
    - require:
      - pkg: git

{{ summarize_giturl }}{{ summarize_dir }}:
  git.latest:
    - name: {{ summarize_giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ summarize_dir }}
    - require:
      - pkg: git

{{ process_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ process_giturl }}{{ process_dir }}

{{ process_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ process_dir }}
    - require:
      - virtualenv: {{ process_dir }}/.ve/

postgres_user_and_db:
  postgres_user.present:
    - name: ocdskfp
    - password: {{ pillar.kingfisher_process.postgres.ocdskfp.password }}

  postgres_database.present:
    - name: ocdskingfisherprocess
    - owner: ocdskfp

{{ summarize_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - cwd: {{ summarize_dir }}
    - requirements: {{ summarize_dir }}/requirements.txt
    - require:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

kfp_postgres_readonlyuser_create:
  postgres_user.present:
    - name: ocdskfpreadonly
    - password: {{ pillar.kingfisher_process.postgres.ocdskfpreadonly.password }}

{{ userdir }}/.pgpass:
  file.managed:
    - source: salt://postgres/kingfisher-process.pgpass
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400

{{ process_dir }}/wsgi.py:
  file.managed:
    - source: salt://wsgi/kingfisher-process.py

{{ userdir }}/.config/ocdskingfisher-process/config.ini:
  file.managed:
    - source: salt://kingfisher-process/config.ini
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

{{ summarize_dir }}/.env:
  file.managed:
    - source: salt://kingfisher-summarize/.env
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400

{{ userdir }}/.config/ocdskingfisher-process/logging.json:
  file.managed:
    - source: salt://kingfisher-process/logging.json
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

{{ userdir }}/.config/kingfisher-summarize/logging.json:
  file.managed:
    - source: salt://kingfisher-summarize/logging.json
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

/etc/rsyslog.d/90-kingfisher.conf:
  file.managed:
    - source: salt://kingfisher-process/rsyslog.conf

/etc/rsyslog.d/91-kingfisher-views.conf:
  file.managed:
    - source: salt://kingfisher-summarize/rsyslog.conf

/etc/logrotate.d/kingfisher.conf:
  file.managed:
    - source: salt://kingfisher-process/logrotate.conf

/etc/logrotate.d/kingfisher-views.conf:
  file.managed:
    - source: salt://kingfisher-summarize/logrotate.conf

restart-syslog:
  cmd.run:
      - name: service rsyslog restart
      - runas: root
      - require:
        - file: /etc/rsyslog.d/90-kingfisher.conf

createdatabase-{{ process_dir }}:
  cmd.run:
    - name: . .ve/bin/activate; python ocdskingfisher-process-cli upgrade-database
    - runas: {{ user }}
    - cwd: {{ process_dir }}
    - require:
      - virtualenv: {{ process_dir }}/.ve/
      - {{ userdir }}/.config/ocdskingfisher-process/config.ini

createdatabase-{{ summarize_dir }}:
  cmd.run:
    - name: . .ve/bin/activate; ./manage.py install
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - virtualenv: {{ summarize_dir }}/.ve/
      - {{ summarize_dir }}/.env

correctuserpermissions-{{ summarize_dir }}:
  cmd.run:
    - name: . .ve/bin/activate; ./manage.py correct-user-permissions
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - cmd: createdatabase-{{ summarize_dir }}

kfp_postgres_schema_creation:
  postgres_schema.present:
    - dbname: ocdskingfisherprocess
    - names:
      - views

kfp_postgres_readonlyuser_setup_as_postgres:
  cmd.run:
    - name: >
          psql
          -c "
          REVOKE ALL ON SCHEMA public, views FROM public;
          GRANT ALL ON SCHEMA public, views TO ocdskfp;
          GRANT USAGE ON SCHEMA public, views TO ocdskfpreadonly;
          GRANT SELECT ON ALL TABLES IN SCHEMA public, views TO ocdskfpreadonly;
          "
          ocdskingfisherprocess
    - runas: postgres
    - cwd: {{ process_dir }}
    - require:
      - {{ userdir }}/.pgpass
      - kfp_postgres_readonlyuser_create
      - {{ process_dir }}/.ve/
      - kfp_postgres_schema_creation

kfp_postgres_readonlyuser_setup_as_user:
  cmd.run:
    - name: psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public, views GRANT SELECT ON TABLES TO ocdskfpreadonly;" ocdskingfisherprocess
    - runas: {{ user }}
    - cwd: {{ process_dir }}
    - require:
      - {{ userdir }}/.pgpass
      - kfp_postgres_readonlyuser_create
      - {{ process_dir }}/.ve/
      - kfp_postgres_readonlyuser_setup_as_postgres
      - kfp_postgres_schema_creation


{{ apache('kingfisher-process', name='ocdskingfisherprocess', servername='process.kingfisher.open-contracting.org') }}

{{ uwsgi('kingfisher-process', name='ocdskingfisherprocess', port=5001) }}


# This is to have eight workers at once.
cd {{ process_dir }}; . .ve/bin/activate; python ocdskingfisher-process-cli --quiet process-redis-queue --runforseconds 3540 > /dev/null:
  cron.present:
    - identifier: OCDS_KINGFISHER_PROCESS_REDIS_QUEUE
    - user: {{ user }}
    - minute: 0,5,15,20,30,35,45,50

cd {{ process_dir }}; . .ve/bin/activate; python ocdskingfisher-process-cli --quiet process-redis-queue-collection-store-finished --runforseconds 3540:
  cron.present:
    - identifier: OCDS_KINGFISHER_PROCESS_REDIS_QUEUE_COLLECTION_STORE_FINISHED
    - user: {{ user }}
    - minute: 0

# This process is a backup; this work should be done by workers on the Redis que.
# So run it once per night. It also takes a while to check all processes, so run for 8 hours.
cd {{ process_dir }}; . .ve/bin/activate; python ocdskingfisher-process-cli --quiet check-collections --runforseconds 28800:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_CHECK_COLLECTIONS
    - user: {{ user }}
    - minute: 0
    - hour: 1

# It takes just under 2 hours to do a full run at the moment, so run for 3 hours.
cd {{ process_dir }}; . .ve/bin/activate; python ocdskingfisher-process-cli --quiet transform-collections --threads 10 --runforseconds 10800:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_TRANSFORM_COLLECTIONS
    - user: {{ user }}
    - hour: 0,3,6,9,12,15,18,21
    - minute: 30

cd {{ process_dir }}; . .ve/bin/activate; python ocdskingfisher-process-cli --quiet delete-collections:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_DELETE_COLLECTIONS
    - user: {{ user }}
    - minute: 0
    - hour: 2
    - dayweek: 5

# Need to manually reload this service - the library code should really do this for us
reload_uwsgi_service:
  cmd.run:
    - name: sleep 10; /etc/init.d/uwsgi reload
    - order: last

kingfisher-process-pipinstall:
  pip.installed:
    - upgrade: True
    - user: {{ user }}
    - requirements: salt://kingfisher-process/pipinstall.txt
    - bin_env: /usr/bin/pip3

kingfisher-process-pip-path:
  file.append:
    - name: {{ userdir }}/.bashrc
    - text: "export PATH=\"{{ userdir }}/.local/bin/:$PATH\""

# We decrease `random_page_cost`, so that the system prefers index scans to sequential scans. If we again notice slow
# queries due to sequential scans, we can decrease it further to, for example, 1.5.
#
# `random_page_cost` is 4.0 by default. When the database is smaller than the total server memory, and when solid-state
# drives are used, it is appropriate to decrease `random_page_cost`.
#
# https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-RANDOM-PAGE-COST
# https://github.com/open-contracting/kingfisher-summarize/issues/92
# https://stackoverflow.com/a/52833441/244258
kfp_postgres_set_random_page_cost:
  cmd.run:
    - name: psql -c "ALTER TABLESPACE pg_default SET (random_page_cost = 2)"
    - runas: postgres


# https://github.com/open-contracting/deploy/issues/117
kingfisher_postgres_extensions:
  cmd.run:
    - name: >
          psql
          -c "
          CREATE EXTENSION IF NOT EXISTS tablefunc;
          "
          ocdskingfisherprocess
    - runas: postgres
    - require:
      - postgres_user_and_db
