# top.sls defines which states should be installed onto which servers
# and is used by the state.highstate command (see README)

base:
  # Install our core sls onto all servers
  '*':
    - core

  # LIVE

  'ocdskingfisher-new':
    - postgres11
    - ocdskingfisher
    - ocdskingfisherold
    - ocdskingfisherarchiveonprocess
    - ocdskingfisherprocess
    - ocdskingfisherscrape
    - ocdskingfisheranalyse
    - prometheus-client-apache


  'ocds-docs-staging':
    - icinga2-satellite
    - prometheus-client-apache
    - ocds-docs-staging
    - tinyproxy

  'ocds-docs-live':
    - icinga2-satellite
    - prometheus-client-apache
    - ocds-docs-live
    - ocds-legacy

  'standard-search':
#    - icinga2-satellite
    - prometheus-client-apache
    - standard-search

  'ocds-redash*':
    - ocds-redash

  'ocdskit-web':
    - ocdskit-web
    - prometheus-client-apache

  'ocds-kingfisher-archive':
    - ocdskingfisher
    - ocdskingfisheranalyse
    - ocdskingfisherarchiveonarchive
    - prometheus-client-apache

  'cove*live*':
    - cove
    - prometheus-client-apache
    - icinga2-satellite


