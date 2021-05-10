include:
  - postgres

# Require official PostgreSQL repo as they provide a newer version of pgbackrest.
pgbackrest:
  pkg.installed:
    - name: pgbackrest
  require:
    - sls: postgresql

/etc/pgbackrest/pgbackrest.conf:
  file.managed:
   - makedirs: True
   - user: postgres
   - group: postgres
   - source: salt://postgres/files/pgbackrest/{{ pillar.postgres.backup.configuration }}.conf
   - template: jinja

{%- if salt['pillar.get']('postgres:backup:cron') %}
# Using file.append rather than the salt cron module.
# Because system crons are easier to find if they are all stored in /etc.
/etc/cron.d/postgres_backups:
  file.managed:
    - contents_pillar: postgres:backup:cron
    - require:
      - pkg: pgbackrest
{%- endif %}
