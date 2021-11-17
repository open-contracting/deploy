{% from 'lib.sls' import create_pg_database %}

include:
  - docker_apps

{{ create_pg_database( "redash_db", "redash_user" ) }}
