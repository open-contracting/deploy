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

{% if salt['pillar.get']('postgres:backup:cron') %}
/etc/cron.d/postgres_backups:
  file.managed:
    - contents_pillar: postgres:backup:cron
    - require:
      - pkg: pgbackrest
{% endif %}
