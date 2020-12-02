# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core

  'cove-*':
    - cove

  'covid19-dev':
    - covid19

  'docs':
    - docs
    - docs-legacy
    - elasticsearch
    - tinyproxy

  'kingfisher-process':
    - postgres
    - kingfisher
    - kingfisher-collect
    - kingfisher-process
    - kingfisher-analyse
    - kingfisher-archive
    - postgres.replica_master

  'kingfisher-replica':
    - postgres

  'prometheus':
    - prometheus-server

  'redash':
    - redash

  'toucan':
    - toucan

  'prometheus_node_exporter:enabled:true':
    - match: pillar
    - prometheus-client-apache

  'maintenance:enabled:true':
    - match: pillar
    - maintenance.hardware_sensors
    - maintenance.patching
    - maintenance.postgres_monitoring
    - maintenance.raid_monitoring
    - maintenance.rkhunter
