# Configure settings specific to the main server for physical replication.

# PostgreSQL's replication slots prevent a main server from removing WAL segments from `pg_wal` that are still needed
# by replica servers. As a fallback, and in case replication slots are not configured, we also have a WAL archive. Old
# archive files are deleted by `/etc/cron.d/replica_monitoring` below.
/var/lib/postgresql/{{ pillar.postgres.version }}/main/archive/:
  file.directory:
    - user: postgres
    - group: postgres
    - makedirs: True
    - mode: 700
    - recurse:
      - user
      - group

/home/sysadmin-tools/bin/delete-after-x-days.sh:
  file.managed:
    - source: salt://files/delete-after-x-days.sh
    - mode: 755
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/postgres_archive_cleanup:
  file.managed:
    - text: |
        MAILTO=root
        15 10 * * * postgres /home/sysadmin-tools/bin/delete-after-x-days.sh 7 /var/lib/postgresql/{{ pillar.postgres.version }}/main/archive/
    - require:
      - file: /home/sysadmin-tools/bin/delete-after-x-days.sh
