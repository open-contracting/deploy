# Set up postgres replication monitoring.
/home/sysadmin-tools/postgres_replication:
  file.directory:
    - user: postgres
    - group: postgres
    - makedirs: True

/home/sysadmin-tools/bin/postgres_replication_monitoring.sh:
  file.managed:
    - source: salt://maintenance/postgres_monitoring/files/replica_monitoring.sh
    - mode: 755
    - require:
      - file: /home/sysadmin-tools/bin

/etc/cron.d/replica_monitoring:
  file.managed:
    - text: |
        MAILTO=root
        10,30,50 * * * * postgres /home/sysadmin-tools/bin/postgres_replication_monitoring.sh
