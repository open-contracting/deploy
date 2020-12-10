# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core
    - core.apt
    - core.customization
    - core.fail2ban
    - core.firewall
    - core.locale
    - core.logrotate
    - core.mail
    - core.motd
    - core.ntp
    - core.rsyslog
    - core.sshd
    - core.swap
    - core.systemd

  'cove-*':
    - cove

  'cove-oc4ids':
    - memcached

  'covid19-dev':
    - covid19

  'docs':
    - docs
    - elasticsearch
    - tinyproxy

  'kingfisher-process':
    - postgres.main
    - redis
    - kingfisher
    - kingfisher.collect
    - kingfisher.process
    - kingfisher.summarize
    - kingfisher.archive

  'prometheus':
    - prometheus.server
    - prometheus.alertmanager

  'redash':
    - redash

  'toucan':
    - toucan

  # https://docs.saltstack.com/en/latest/topics/targeting/compound.html

  'I@apache:htpasswd':
    - apache.htpasswd

  'I@apache:sites':
    - apache.public
    # So far, all servers with sites configure a reverse proxy.
    - apache.modules.proxy_http

  'I@postgres:configuration':
    - postgres

  'I@prometheus:node_exporter:enabled:true':
    - prometheus.node_exporter

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
