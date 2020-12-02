{% from 'lib.sls' import createuser, uwsgi, apache %}

include:
  - apache.public
  - apache.modules.proxy_http
  - apache.modules.proxy_uwsgi
  - uwsgi

kingfisher-process-prerequisites:
  pkg.installed:
    - pkgs:
      - python-pip
      - python3-pip
      - python3-virtualenv
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
{{ createuser(user, authorized_keys=pillar.ssh.kingfisher) }}

{% set process_giturl = 'https://github.com/open-contracting/kingfisher-process.git' %}
{% set summarize_giturl = 'https://github.com/open-contracting/kingfisher-summarize.git' %}
{% set process_dir = userdir + '/ocdskingfisherprocess' %}
{% set summarize_dir = userdir + '/ocdskingfisherviews' %}

####################
# Git repositories
####################

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

####################
# Python packages
####################

{{ process_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ process_giturl }}{{ process_dir }}

{{ summarize_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

{{ process_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ process_dir }}
    - require:
      - virtualenv: {{ process_dir }}/.ve/

{{ summarize_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - virtualenv: {{ summarize_dir }}/.ve/

####################
# Configuration
####################

{{ userdir }}/.pgpass:
  file.managed:
    - source: salt://postgres/kingfisher-process.pgpass
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400

{{ userdir }}/.config/ocdskingfisher-process/config.ini:
  file.managed:
    - source: salt://kingfisher-process/config.ini
    - template: jinja
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True

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

{{ process_dir }}/wsgi.py:
  file.managed:
    - source: salt://wsgi/kingfisher-process.py
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - git: {{ process_giturl }}{{ process_dir }}

{{ summarize_dir }}/.env:
  file.managed:
    - source: salt://kingfisher-summarize/.env
    - user: {{ user }}
    - group: {{ user }}
    - mode: 0400
    - require:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

####################
# Logging
####################

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
        - file: /etc/rsyslog.d/91-kingfisher-views.conf

####################
# PostgreSQL
####################

# https://github.com/jfcoz/postgresqltuner
pg_stat_statements:
  postgres_extension.present:
    - maintenance_db: template1
    - if_not_exists: True

user_ocdskfp:
  postgres_user.present:
    - name: ocdskfp
    - password: {{ pillar.postgres.ocdskfp.password }}

user_ocdskfpreadonly:
  postgres_user.present:
    - name: ocdskfpreadonly
    - password: {{ pillar.postgres.ocdskfpreadonly.password }}

db_ocdskingfisherprocess:
  postgres_database.present:
    - name: ocdskingfisherprocess
    - owner: ocdskfp
    - require:
      - postgres_user: user_ocdskfp

# https://github.com/open-contracting/deploy/issues/117
tablefunc:
  postgres_extension.present:
    - maintenance_db: ocdskingfisherprocess
    - if_not_exists: True
    - require:
      - postgres_database: db_ocdskingfisherprocess

####################
# App installation
####################

{{ process_dir }}-install:
  cmd.run:
    - name: . .ve/bin/activate; python ocdskingfisher-process-cli upgrade-database
    - runas: {{ user }}
    - cwd: {{ process_dir }}
    - require:
      - cmd: {{ process_dir }}-requirements
      - file: {{ userdir }}/.pgpass
      - file: {{ userdir }}/.config/ocdskingfisher-process/config.ini
      - postgres_database: db_ocdskingfisherprocess

{{ summarize_dir }}-install:
  cmd.run:
    - name: . .ve/bin/activate; ./manage.py install
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - cmd: {{ summarize_dir }}-requirements
      - file: {{ userdir }}/.pgpass
      - file: {{ summarize_dir }}/.env
      - postgres_database: db_ocdskingfisherprocess

correctuserpermissions-{{ summarize_dir }}:
  cmd.run:
    - name: . .ve/bin/activate; ./manage.py correct-user-permissions
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - cmd: {{ summarize_dir }}-install

kfp_postgres_readonlyuser_setup_as_postgres:
  cmd.run:
    - name: >
          psql -c "
          REVOKE ALL ON SCHEMA public, views FROM public;
          GRANT ALL ON SCHEMA public, views TO ocdskfp;
          GRANT USAGE ON SCHEMA public, views TO ocdskfpreadonly;
          GRANT SELECT ON ALL TABLES IN SCHEMA public, views TO ocdskfpreadonly;
          ALTER DEFAULT PRIVILEGES IN SCHEMA public, views GRANT SELECT ON TABLES TO ocdskfpreadonly;
          "
          ocdskingfisherprocess
    - runas: postgres
    - require:
      - cmd: {{ process_dir }}-install
      - cmd: {{ summarize_dir }}-install
      - postgres_user: user_ocdskfpreadonly

{{ apache('kingfisher-process', name='ocdskingfisherprocess', servername='process.kingfisher.open-contracting.org') }}

{{ uwsgi('kingfisher-process', name='ocdskingfisherprocess', port=5001) }}

# Need to manually reload this service - the library code should really do this for us
reload_uwsgi_service:
  cmd.run:
    - name: sleep 10; /etc/init.d/uwsgi reload
    - order: last

####################
# Cron jobs
####################

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

####################
# Utilities
####################

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
