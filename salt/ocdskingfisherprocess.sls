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

{% set user = 'ocdskfp' %}
{{ createuser(user, auth_keys_files=['kingfisher']) }}
{% set giturl = 'https://github.com/open-contracting/kingfisher-process.git' %}
{% set views_giturl = 'https://github.com/open-contracting/kingfisher-views.git' %}

{% set userdir = '/home/' + user %}
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
    - cwd: {{ ocdskingfisherdir }}
    - requirements: {{ ocdskingfisherdir }}requirements.txt
    - require:
      - git: {{ giturl }}{{ ocdskingfisherdir }}

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


kfp_postgres_guest_create:
  postgres_user.present:
    - name: ocdskfpguest
    - password: {{ pillar.ocdskingfisherprocess.postgres.ocdskfpguest.password }}


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

/etc/rsyslog.d/90-kingfisher.conf:
  file.managed:
    - source: salt://ocdskingfisherprocess/rsyslog.conf

/etc/logrotate.d/kingfisher.conf:
  file.managed:
    - source: salt://ocdskingfisherprocess/logrotate.conf

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
    - name: . .ve/bin/activate; python ocdskingfisher-views-cli upgrade-database
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
  cmd.run:
    - name: >
          psql
          -c "create schema if not exists views; create schema if not exists views_test; create schema if not exists view_info; create schema if not exists view_meta;"
          ocdskingfisherprocess
    - runas: postgres
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - {{ userdir }}/.pgpass
      - {{ ocdskingfisherdir }}.ve/

kfp_postgres_readonlyuser_setup_as_postgres:
  cmd.run:
    - name: >
          psql
          -c "
          REVOKE ALL ON schema public, views, views_test, view_info, view_meta FROM public;
          GRANT ALL ON schema public, views, views_test, view_info, view_meta TO ocdskfp;
          GRANT USAGE ON schema public, views, views_test, view_info, view_meta TO ocdskfpreadonly, ocdskfpguest;
          GRANT SELECT ON ALL TABLES IN SCHEMA public, views, views_test, view_info, view_meta TO ocdskfpreadonly, ocdskfpguest;
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
    - name: psql -c "ALTER DEFAULT PRIVILEGES IN SCHEMA public, views, views_test GRANT SELECT ON TABLES TO ocdskfpreadonly, ocdskfpguest;" ocdskingfisherprocess
    - runas: {{ user }}
    - cwd: {{ ocdskingfisherdir }}
    - require:
      - {{ userdir }}/.pgpass
      - kfp_postgres_readonlyuser_create
      - {{ ocdskingfisherdir }}.ve/
      - kfp_postgres_readonlyuser_setup_as_postgres
      - kfp_postgres_schema_creation


{{ apache('ocdskingfisherprocess.conf',
    name='ocdskingfisherprocess.conf',
    servername='process.kingfisher.open-contracting.org') }}

{{ uwsgi('ocdskingfisherprocess.ini',
    name='ocdskingfisherprocess.ini',
    port=5001) }}


# This is to have eight workers at once.
cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli process-redis-queue --runforseconds 3540:
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
cd {{ ocdskingfisherdir }}; . .ve/bin/activate; python ocdskingfisher-process-cli transform-collections --runforseconds 10800:
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

cd {{ ocdskingfisherviewsdir }}; . .ve/bin/activate; python ocdskingfisher-views-cli refresh-views --logfile=~/refresh-view.log; python ocdskingfisher-views-cli field-counts --threads=5 --logfile=~/fields-counts.log:
  # Change to cron.present when ready to restore functionality.
  cron.absent:
    - identifier: OCDS_KINGFISHER_VIEWS_RUN
    - user: {{ user }}
    - minute: 0
    - hour: 22

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
    - name: /home/{{ user }}/.bashrc
    - text: "export PATH=\"/home/{{ user }}/.local/bin/:$PATH\""
