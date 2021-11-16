{% from 'lib.sls' import create_pg_database %}

include:
  - docker

# =================================================================================================
# See https://ocdsdeploy.readthedocs.io/en/latest/deploy/redash.html for installation instructions.
# =================================================================================================

# Create Redash configuration and directories
/opt/redash/env:
  file.managed:
    - source: salt://redash/files/env
    - mode: 600
    - makedirs: True
    - template: jinja

/opt/redash/docker-compose.yml:
  file.managed:
    - source: salt://redash/files/docker-compose.yml
    - mode: 644
    - template: jinja

{{ create_pg_database( pillar.redash.postgres.database, pillar.redash.postgres.username ) }}
