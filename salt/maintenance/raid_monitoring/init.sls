# Install hardware RAID monitoring script
/home/sysadmin-tools/raid:
  file.directory:
    - makedirs: True

/etc/cron.hourly/raid_monitoring:
  file.managed:
    - source: salt://maintenance/raid_monitoring/files/{{ pillar.maintenance.raid_monitoring_script }}
    - mode: 755
