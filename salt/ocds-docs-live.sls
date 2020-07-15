include:
  - apache
  - ocds-docs-common

# Needed to create a ZIP file of the schema and codelists.
# https://ocdsdeploy.readthedocs.io/en/latest/deploy/docs.html#copy-the-schema-and-zip-file-into-place
zip:
  pkg.installed

ocds-docs-live modules:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http

# These will be served the same as files that were copied into place.
https://github.com/open-contracting/standard-legacy-staticsites.git:
  git.latest:
    - rev: master
    - target: /home/ocds-docs/web/legacy/
    - user: ocds-docs
    - force_fetch: True
    - force_reset: True

# Create the file in the virtual host's document root.
/home/ocds-docs/web/robots.txt:
  file.managed:
    - source: salt://ocds-docs/robots_live.txt
    - user: ocds-docs
