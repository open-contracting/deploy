#
# Install postgres from the official repositories as they offer newer versions than os repos
# 

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
    - name: postgresql-{{ pillar["postgres"]["version"] }}
  service.running:
    - enable: True

# Upload configuration for postgres
# Postgres servers will all have custom configuration so it checks for a local directory with the same target ID
# If it can't find this it falls back to the default directory.
/etc/postgresql/{{ pillar["postgres"]["version"] }}/main/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source: 
      - salt://postgres/configs/pg_hba.conf
    - template: jinja
    - watch_in:
      - service: postgresql 

# Upload custom configuration if defined
{% if pillar['postgres']['custom_configuration'] %}
/etc/postgresql/{{ pillar["postgres"]["version"] }}/main/conf.d/030_{{ grains['id'] }}.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source: 
      - {{ pillar['postgres']['custom_configuration'] }}
    - watch_in:
      - service: postgresql 
{% endif %}
