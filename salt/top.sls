# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core
    - core.apt
    - core.customization
    - core.fail2ban
    - core.firewall
    - core.locale
    - core.mail
    - core.motd
    - core.ntp
    - core.sshd
    - core.swap
    - core.systemd

  'docs':
    - docs
    - docs-legacy
    - tinyproxy
    - prometheus-client-apache

  'standard-search':
    - standard-search
    - prometheus-client-apache

  'redash':
    - redash
    - prometheus-client-apache

  'toucan':
    - toucan
    - prometheus-client-apache

  'cove-*':
    - cove
    - prometheus-client-apache

  'kingfisher-process':
    - postgres
    - kingfisher
    - kingfisher-collect
    - kingfisher-process
    - kingfisher-analyse
    - kingfisher-archive
    - prometheus-client-apache

  'kingfisher-process':
    - postgres.replica_master

  'kingfisher-replica':
    - postgres
    - prometheus-client-apache

  'prometheus':
    - prometheus-server
    - prometheus-client-apache

  'maintenance:enabled:true':
    - match: pillar
    - maintenance.hardware_sensors
    - maintenance.patching
    - maintenance.postgres_monitoring
    - maintenance.raid_monitoring
    - maintenance.rkhunter

  'covid19-dev':
    - covid19
