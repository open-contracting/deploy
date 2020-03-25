include:
  - docker

#### Setup Instructions on new box
#
# These are not in salt because once installed the files have state that should not change.
#
# 1. Create a config file.
# Look in https://github.com/getredash/setup/blob/master/setup.sh and follow the instructions in create_config function.
# Start by setting
#   REDASH_BASE_PATH=/opt/redash
# then run the  commands from that function by hand (ignore stuff in  "if [[ -e $REDASH_BASE_PATH/env ]]; then" )
#
# 2. Create a Docker compose file
# This is based on the setup_compose part of https://github.com/getredash/setup/blob/master/setup.sh
# The only state in the docker compose file is what version of redash we are locking to. But this is how they do it so ....
# Start by setting
#   REDASH_BASE_PATH=/opt/redash
# then run the  commands from that function by hand, starting at the top and until you get to echoing stuff to profile
#
# 3. Edit Docker Compose file to move port
# Edit /opt/redash/docker-compose.yml
# Find machine nginx and edit port to: "9090:80"
#
# 4. Finally start app!
#   cd /opt/redash
#   docker-compose run --rm server create_db
#   docker-compose up -d
#
#
#### UPGRADE instructions on existing box
#
# Follow https://redash.io/help/open-source/admin-guide/how-to-upgrade
#

redash_prepackages:
  pkg.installed:
    - pkgs:
      - pwgen


/opt/redash/postgres-data:
  file.directory:
    - user: root
    - group: root
    - makedirs: True

# TODO make sure this restart after server start.
# They have https://github.com/getredash/setup/blob/master/data/docker-compose-up.service but no instructions to install it!?
# Is this the better way to achieve this?