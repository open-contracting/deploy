# Install postgres from the official repositories as they offer newer versions than os repos.

# To ensure apt-transport-https is installed.
include:
 - core

# Default to postgres version 11, if not defined in pillar.
{% set pg_version = salt['pillar.get']('postgres:version', '11') %}

# Install and start postgres.
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

# Upload access configuration for postgres.
/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source:
      - salt://postgres/configs/pg_hba.conf
    - template: jinja
    - watch_in:
      - service: postgresql

# Upload custom configuration if defined.
{% if pillar['postgres']['custom_configuration'] %}
/etc/postgresql/{{ pg_version }}/main/conf.d/030_{{ grains['id'] }}.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source:
      - {{ pillar['postgres']['custom_configuration'] }}
    - watch_in:
      - service: postgresql
{% endif %}
