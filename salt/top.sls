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

  'coalition':
    - coalition

  'cove-*':
    - cove

  'cove-oc4ids':
    - memcached

  'credere':
    - docker_apps

  'docs':
    - docs
    - elasticsearch
    - elasticsearch.plugins.readonlyrest
    - tinyproxy

  'kingfisher-main':
    - rabbitmq
    - kingfisher
    - kingfisher.collect
    - kingfisher.collect.incremental
    - kingfisher.collect_generic
    - kingfisher.process
    - kingfisher.summarize
    - pelican.backend
    - pelican.frontend

  'prometheus':
    - prometheus

  'redash':
    - docker_apps

  'redmine':
    - redmine

  'registry':
    - rabbitmq
    - kingfisher.collect
    - pelican.backend
    - spoonbill
    - registry

  # https://docs.saltproject.io/en/latest/topics/targeting/compound.html

  'I@apache:sites':
    - apache
    # The rabbitmq and proxy configurations can be used without service-specific state files.
    - apache.modules.proxy_http

  # All public web servers should use SSL certificates.
  'I@apache:public_access:true':
    - apache.letsencrypt

  'I@redmine:backup':
    - redmine.backup

  'I@mysql:configuration':
    - mysql

  'I@mysql:backup':
    - mysql.backup

  'I@postgres:configuration':
    - postgres

  'I@postgres:backup':
    - postgres.backup

  'I@prometheus:node_exporter':
    - prometheus.node_exporter

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
