{% from 'lib.sls' import createuser, uwsgi, apache %}

# Set up the server
# ... these bits are in ocdskingfisher.sls
# ... /etc/motd:

include:
  - apache
  - uwsgi

ocdskingfisherprocess-prerequisites:
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

{% set giturl = 'https://github.com/open-contracting/kingfisher-process.git' %}
{% set views_giturl = 'https://github.com/open-contracting/kingfisher-views.git' %}
{% set ocdskingfisherdir = userdir + '/ocdskingfisherprocess/' %}
{% set ocdskingfisherviewsdir = userdir + '/ocdskingfisherviews/' %}

{{ giturl }}{{ ocdskingfisherdir }}:
  git.latest:
    - name: {{ giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ ocdskingfisherdir }}
    - require:
      - pkg: git

{{ views_giturl }}{{ ocdskingfisherviewsdir }}:
  git.latest:
    - name: {{ views_giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ ocdskingfisherviewsdir }}
    - require:
      - pkg: git

{{ ocdskingfisherdir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ giturl }}{{ ocdskingfisherdir }}

pip_install_requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - virtualenv: {{ ocdskingfisherdir }}.ve/

postgres_user_and_db:
  postgres_user.present:
    - name: ocdskfp
    - password: {{ pillar.ocdskingfisherprocess.postgres.ocdskfp.password }}

  postgres_database.present:
    - name: ocdskingfisherprocess
    - owner: ocdskfp

{{ ocdskingfisherviewsdir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - cwd: {{ ocdskingfisherviewsdir }}
    - requirements: {{ ocdskingfisherviewsdir }}requirements.txt
    - require:
      - git: {{ views_giturl }}{{ ocdskingfisherviewsdir }}

kfp_postgres_readonlyuser_create:
  postgres_user.present:
    - name: ocdskfpreadonly
    - password: {{ pillar.ocdskingfisherprocess.postgres.ocdskfpreadonly.password }}

{{ userdir }}/.pgpass:
  file.managed:
    - source: salt://postgres/ocdskingfisher_process_.pgpass
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400

{{ ocdskingfisherdir }}/wsgi.py:
  file.managed:
    - source: salt://wsgi/ocdskingfisherprocess.py

{{ userdir }}/.config/ocdskingfisher-process/config.ini:
  file.managed:
    - source: salt://ocdskingfisherprocess/config.ini
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

{{ userdir }}/.config/ocdskingfisher-views/config.ini:
  file.managed:
    - source: salt://ocdskingfisherviews/config.ini
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

{{ userdir }}/.config/ocdskingfisher-process/logging.json:
  file.managed:
    - source: salt://ocdskingfisherprocess/logging.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - context:
        userdir: {{ userdir }}

{{ userdir }}/.config/ocdskingfisher-views/logging.json:
  file.managed:
    - source: salt://ocdskingfisherviews/logging.json
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - context:
        userdir: {{ userdir }}

/etc/rsyslog.d/90-kingfisher.conf:
  file.managed:
    - source: salt://ocdskingfisherprocess/rsyslog.conf

/etc/rsyslog.d/91-kingfisher-views.conf:
  file.managed:
    - source: salt://ocdskingfisherviews/rsyslog.conf

/etc/logrotate.d/kingfisher.conf:
  file.managed:
    - source: salt://ocdskingfisherprocess/logrotate.conf

/etc/logrotate.d/kingfisher-views.conf:
  file.managed:
    - source: salt://ocdskingfisherviews/logrotate.conf

restart-syslog:
  cmd.run:
      - name: service rsyslog restart
      - runas: root
      - require:
        - file: /etc/rsyslog.d/90-kingfisher.conf

createdatabase-{{ ocdskingfisherdir }}:
  cmd.run:
    - name: . .ve/bin/activate; python ocdskingfisher-process-cli upgrade-database
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - virtualenv: {{ ocdskingfisherdir }}.ve/
      - {{ userdir }}/.config/ocdskingfisher-process/config.ini

createdatabase-{{ ocdskingfisherviewsdir }}:
  cmd.run:
    - name: . .ve/bin/activate; python ocdskingfisher-views-cli install
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherviewsdir }}
    - require:
      - virtualenv: {{ ocdskingfisherviewsdir }}.ve/
      - {{ userdir }}/.config/ocdskingfisher-views/config.ini

correctuserpermissions-{{ ocdskingfisherviewsdir }}:
  cmd.run:
    - name: . .ve/bin/activate; python ocdskingfisher-views-cli correct-user-permissions
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherviewsdir }}
    - require:
      - cmd: createdatabase-{{ ocdskingfisherviewsdir }}

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
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - {{ userdir }}/.pgpass
      - kfp_postgres_readonlyuser_create
      - {{ ocdskingfisherdir }}.ve/
      - kfp_postgres_schema_creation

kfp_postgres_readonlyuser_setup_as_user:
  cmd.run:
    - name: psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public, views GRANT SELECT ON TABLES TO ocdskfpreadonly;" ocdskingfisherprocess
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - {{ userdir }}/.pgpass
      - kfp_postgres_readonlyuser_create
      - {{ ocdskingfisherdir }}.ve/
      - kfp_postgres_readonlyuser_setup_as_postgres
      - kfp_postgres_schema_creation


{{ apache('ocdskingfisherprocess', servername='process.kingfisher.open-contracting.org') }}

{{ uwsgi('ocdskingfisherprocess', port=5001) }}


# This is to have eight workers at once.
cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli process-redis-queue --runforseconds 3540 > /dev/null:
  cron.present:
    - identifier: OCDS_KINGFISHER_PROCESS_REDIS_QUEUE
    - user: {{ user }}
    - minute: 0,5,15,20,30,35,45,50

cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli process-redis-queue-collection-store-finished --runforseconds 3540:
  cron.present:
    - identifier: OCDS_KINGFISHER_PROCESS_REDIS_QUEUE_COLLECTION_STORE_FINISHED
    - user: {{ user }}
    - minute: 0

# This process is a backup; this work should be done by workers on the Redis que.
# So run it once per night. It also takes a while to check all processes, so run for 8 hours.
cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli check-collections --runforseconds 28800:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_CHECK_COLLECTIONS
    - user: {{ user }}
    - minute: 0
    - hour: 1

# It takes just under 2 hours to do a full run at the moment, so run for 3 hours.
cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli transform-collections --threads 10 --runforseconds 10800:
  cron.present:
    - identifier: OCDS_KINGFISHER_SCRAPE_TRANSFORM_COLLECTIONS
    - user: {{ user }}
    - hour: 0,3,6,9,12,15,18,21
    - minute: 30

cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli delete-collections:
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

ocdskingfisherprocess-pipinstall:
  pip.installed:
    - upgrade: True
    - user: {{ user }}
    - requirements: salt://ocdskingfisherprocess/pipinstall.txt
    - bin_env: /usr/bin/pip3

ocdskingfisherprocess-pip-path:
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
# https://github.com/open-contracting/kingfisher-views/issues/92
# https://stackoverflow.com/a/52833441/244258
kfp_postgres_set_random_page_cost:
  cmd.run:
    - name: psql -c "ALTER TABLESPACE pg_default SET (random_page_cost = 2)"
    - runas: postgres


# https://github.com/open-contracting/deploy/issues/117
kingfisher_views_postgres_extensions:
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
