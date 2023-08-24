include:
  - python

# https://www.psycopg.org/install/
psycopg2:
  pkg.installed:
    - pkgs:
      - python{{ salt['pillar.get']('python:version', 3) }}-dev
      - libpq-dev
