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

  'cove-*':
    - cove

  'covid19-dev':
    - covid19

  'docs':
    - docs
    - elasticsearch
    - tinyproxy

  'kingfisher-process':
    - postgres
    - postgres.main
    - kingfisher
    - kingfisher.collect
    - kingfisher.process
    - kingfisher.analyse
    - kingfisher.archive

  'kingfisher-replica':
    - postgres

  'prometheus':
    - prometheus.server
    - prometheus.alertmanager

  'redash':
    - redash

  'toucan':
    - toucan

  # https://docs.saltstack.com/en/latest/topics/targeting/compound.html
  'I@prometheus_node_exporter:enabled:true':
    - prometheus-client-apache

  'I@maintenance:enabled:true':
    - maintenance.rkhunter

  'I@maintenance:enabled:true and I@maintenance:hardware_sensors:true':
    - maintenance.hardware_sensors

  'I@maintenance:enabled:true and I@maintenance:patching:automatic':
    - maintenance.patching

  'I@maintenance:enabled:true and I@maintenance:patching:manual':
    - maintenance.patching.absent

  'I@maintenance:enabled:true and I@postgres:replica_user':
    - maintenance.postgres_monitoring

  'I@maintenance:enabled:true and I@maintenance:raid_monitoring_script':
    - maintenance.raid_monitoring
