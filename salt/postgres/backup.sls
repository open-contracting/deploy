include:
  - postgres

# Require official PostgreSQL repo as they provide a newer version of pgbackrest.
pgbackrest:
  pkg.installed: []
  require: 
    - sls: postgresql

/etc/pgbackrest/pgbackrest.conf:
  file.managed:
   - makedirs: True
   - user: postgres
   - group: postgres
   - source: salt://postgres/files/pgbackrest/{{ pillar.pgbackrest_config_name }}.conf
   - template: jinja
