# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core
    - core.sshd
    - core.swap
    - core.mail
    - core.fail2ban
    - core.locale
    - core.ntp
    - core.motd
    - core.apt
    - core.systemd
    - core.customisation

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

  'prometheus':
    - prometheus-client-apache
    - prometheus-server
