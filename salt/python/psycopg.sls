include:
  - python

# https://www.psycopg.org/psycopg3/docs/basic/install.html#local-installation
psycopg:
  pkg.installed:
    - pkgs:
      - python{{ salt['pillar.get']('python:version', 3) }}-dev
      - libpq-dev
