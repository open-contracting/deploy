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
   - source: salt://postgres/files/pgbackrest/{{ pillar.postgres.backup.config_name }}.conf
   - template: jinja

{%- if salt['pillar.get']('postgres:backup:enabled','') == True %}
# Using file.append rather than the salt cron module.
# Because system crons are easier to find if they are all stored in /etc.
/etc/cron.d/postgres_backups:
  file.append:
    - text: |
        MAILTO=root
        # Daily incremental backup
        15 05 * * 1-6 postgres pgbackrest backup
        # Weekly full backup
        15 05 * * 7 postgres pgbackrest backup --type=full
    - require:
      - pkg: pgbackrest
{%- endif %}
