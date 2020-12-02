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
    - kingfisher
    - kingfisher.collect
    - kingfisher.process
    - kingfisher.analyse
    - kingfisher.archive
    - postgres.main

  'kingfisher-replica':
    - postgres

  'prometheus':
    - prometheus.server
    - prometheus.alertmanager

  'redash':
    - redash

  'toucan':
    - toucan

  'prometheus_node_exporter:enabled:true':
    - match: pillar
    - prometheus-client-apache

  'maintenance:patching:automatic':
    - match: pillar
    - maintenance.patching

  'maintenance:patching:manual':
    - match: pillar
    - maintenance.patching.absent

  'maintenance:enabled:true':
    - match: pillar
    - maintenance.hardware_sensors
    - maintenance.postgres_monitoring
    - maintenance.raid_monitoring
    - maintenance.rkhunter
