{% from 'lib.sls' import apache %}


include:
  - docker
  - apache-proxy


#
#
#
# ========================================================================================================
# IMPORTANT
# NOT EVERYTHING IS IN SALT!
# You were thinking this file looked a bit empty weren't you?
# See docs/deploy/redash.rst or https://ocdsdeploy.readthedocs.io/en/latest/deploy/redash.html for more
# ========================================================================================================
#
#
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
