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


  'ocds-docs-staging':
    - icinga2-satellite
    - ocds-docs-staging
    - tinyproxy

  'ocds-docs-live':
    - icinga2-satellite
    - ocds-docs-live
    - ocds-legacy

  'standard-search':
#    - icinga2-satellite
    - standard-search

  'ocds-redash*':
    - ocds-redash

  'ocdskit-web':
    - ocdskit-web

  'ocds-kingfisher-archive':
    - ocdskingfisher
    - ocdskingfisheranalyse
    - ocdskingfisherarchiveonarchive

  'cove*live*':
    - cove
    - icinga2-satellite


