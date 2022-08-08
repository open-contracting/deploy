# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core
    - core.apt
    - core.customization
    - core.fail2ban
    - core.firewall
    - core.journald
    - core.locale
    - core.logrotate
    - core.mail
    - core.motd
    - core.network
    - core.rsyslog
    - core.sshd
    - core.swap
    - core.systemd.logind
    - core.systemd.ntp

  'cove-*':
    - cove

  'cove-oc4ids':
    - memcached

  'covid19*':
    - rabbitmq
    - covid19

  'docs':
    - docs
    - elasticsearch
    - elasticsearch.plugins.readonlyrest
    - tinyproxy

  'kingfisher-process':
    - postgres.main
    - redis
    - kingfisher
    - kingfisher.collect
    - kingfisher.collect.incremental
    - kingfisher.process
    - kingfisher.summarize

  'prometheus':
    - prometheus

  'redash':
    - docker_apps

  'registry':
    - rabbitmq
    - kingfisher.collect
    - pelican.backend
    - spoonbill
    - registry

  'toucan':
    - toucan

  # https://docs.saltstack.com/en/latest/topics/targeting/compound.html

  'I@apache:sites':
    - apache
    # So far, all servers with sites configure a reverse proxy.
    - apache.modules.proxy_http

  # All public web servers should use SSL certificates.
  'I@apache:public_access:true':
    - apache.letsencrypt

  'I@postgres:configuration':
    - postgres

  'I@postgres:backup':
    - postgres.backup

  'I@prometheus:node_exporter':
    - prometheus.node_exporter

  'I@mysql:configuration':
    - mysql

  'I@maintenance:enabled:true':
    - maintenance.rkhunter

  'I@maintenance:enabled:true and I@maintenance:hardware_sensors:true':
    - maintenance.hardware_sensors

  'I@maintenance:enabled:true and I@maintenance:patching:automatic':
    - maintenance.patching

  'I@maintenance:enabled:true and I@maintenance:patching:manual':
    - maintenance.patching.absent

  'I@maintenance:enabled:true and I@postgres:users:replica':
    - maintenance.postgres_monitoring

  'I@maintenance:enabled:true and I@maintenance:raid_monitoring_script':
    - maintenance.raid_monitoring
