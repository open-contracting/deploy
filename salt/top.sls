# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core
    - core.apt
    - core.customization
    - core.fail2ban
    - core.locale
    - core.mail
    - core.motd
    - core.ntp
    - core.sshd
    - core.swap
    - core.systemd

  'ocds-docs-staging':
    - prometheus-client-apache
    - ocds-docs-staging
    - tinyproxy

  'ocds-docs-live':
    - prometheus-client-apache
    - ocds-docs-live
    - ocds-legacy

  'standard-search':
    - prometheus-client-apache
    - standard-search

  'redash2':
    - redash
    - prometheus-client-apache

  'toucan':
    - toucan
    - prometheus-client-apache

  'kingfisher-archive':
    - ocdskingfisher
    - ocdskingfisheranalyse
    - ocdskingfisherarchiveonarchive
    - prometheus-client-apache

  'cove-*':
    - cove
    - prometheus-client-apache

  'kingfisher-process*':
    - postgres
    - ocdskingfisher
    - ocdskingfisherarchiveonprocess
    - ocdskingfishercollect
    - ocdskingfisherprocess
    - ocdskingfisheranalyse
    - prometheus-client-apache

  'kingfisher-process1':
    - postgres.replica_master

  'kingfisher-replica*':
    - postgres

  'prometheus':
    - prometheus-client-apache
    - prometheus-server

  'maintenance:enabled:true':
    - match: pillar
    - maintenance.hardware_sensors
    - maintenance.patching
    - maintenance.postgres_monitoring
    - maintenance.raid_monitoring
    - maintenance.rkhunter
