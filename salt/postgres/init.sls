#
# Install postgres from the official repositories as they offer newer versions than os repos
# 

# Set postgres version as a variable to be a bit more future proof
{% set pg_version = "11" %}

# For the apt-transport-https check
include: 
 - core

# Install and start postgres
postgresql:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb https://apt.postgresql.org/pub/repos/apt/ {{ grains['oscodename'] }}-pgdg main
    - dist: {{ grains['oscodename'] }}-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
    - require:
      - pkg: apt-transport-https
  pkg.installed:
    - name: postgresql-{{ pg_version }}
  service.running:
    - enable: True

# Upload configuration for postgres
# Postgres servers will all have custom configuration so it checks for a local directory with the same target ID
# If it can't find this it falls back to the default directory.
/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source: 
      - salt://postgres/{{ grains['id'] }}/pg_hba.conf
      - salt://postgres/default/pg_hba.conf
    - watch_in:
      - service: postgresql 

/etc/postgresql/{{ pg_version }}/main/conf.d/030_{{ grains['id'] }}.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source: 
      - salt://postgres/{{ grains['id'] }}/postgres.conf
      - salt://postgres/default/postgres.conf
    - watch_in:
      - service: postgresql 

