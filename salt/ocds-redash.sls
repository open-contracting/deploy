{% from 'lib.sls' import apache %}


include:
  - docker
  - apache-proxy

#### Setup Instructions on new box
#
# 1. Run mkdir -p /opt/redash/postgres-data
# Once this is made, the user permissions on it must not be changed. So it is in here. and not a salt instruction.
#
#
# These are not in salt because once installed the files have state that should not change.
# (Maybe work into salt later, but have to check if time is worth it given it only runs once)
#
# 2. Create a config file.
# Look in https://github.com/getredash/setup/blob/master/setup.sh and follow the instructions in create_config function.
# Start by setting
#   REDASH_BASE_PATH=/opt/redash
# then run the  commands from the create_config function by hand (ignore stuff in  "if [[ -e $REDASH_BASE_PATH/env ]]; then" )
#
# Note: If migrating from an old server, you must now edit /opt/redash/env and set REDASH_COOKIE_SECRET and REDASH_SECRET_KEY
# to be the same as the old server.
#
# 3. Create a Docker compose file
# This is based on the setup_compose function of https://github.com/getredash/setup/blob/master/setup.sh
# The only state in the docker compose file is what version of redash we are locking to. But this is how they do it so ....
# Start by setting
#   REDASH_BASE_PATH=/opt/redash
# then run the  commands from the setup_compose by hand, starting at the top and until you get to echoing stuff to profile
#
#
# 4. Edit Docker Compose file to move port
# Edit /opt/redash/docker-compose.yml
# Find machine nginx and edit port to: "9090:80"
#
# 5. Finally start app - if totally now
# (Note: this is taken from setup_compose function of https://github.com/getredash/setup/blob/master/setup.sh )
#   cd /opt/redash
#   docker-compose run --rm server create_db
#   docker-compose up -d
#
#   OR
#
# 5. Finally, start app - If moving from an old server
#
#   cd /opt/redash
#
# You must edit the docker-compose.yml file to make available the postgres server. To the postgres server add:
#    ports:
#      - "5432:5432"
#
#   docker-compose up -d
#
# Dump the Postgres database on the old server and import it to the new server.
# Look in /opt/redash/env for database settings to use in new server.
#
#   docker-compose run --rm server create_db
#
# Edit docker-compose.yml and remove the postgres port (for better security). To make that change active, again run:
#
#   docker-compose up -d

#### UPGRADE instructions on existing box
#
# Follow https://redash.io/help/open-source/admin-guide/how-to-upgrade
#

#### CONFIG SETUP
#
# Edit /opt/redash/env
#
# 1. We want REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL
#   Add
#   REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL=true
#
# 2. Email sending
# See https://redash.io/help/open-source/setup#Mail-Configuration and set REDASH_HOST too.
# note: the send_test_mail command did not work for me but just putting my email in "Forgotten Password" did.
#
#


#### To restart redash for any reason (just edited config, etc)
#
# cd /opt/redash/
# docker-compose stop
# docker-compose up -d
#

redash_prepackages:
  pkg.installed:
    - pkgs:
      - pwgen
      - postgresql-client-10


/opt/redash:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

{{ apache('redash.conf',
    name='redash.conf',
    servername=pillar.redash.server_name,
    https=pillar.redash.https) }}
