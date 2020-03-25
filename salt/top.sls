# Defines which states should be applied for each target and is used by the state.apply command.

base:
  '*':
    - core

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

  'ocds-redash':
    - ocds-redash
    - prometheus-client-apache

  'toucan':
    - toucan
    - prometheus-client-apache

  'ocds-kingfisher-archive':
    - ocdskingfisher
    - ocdskingfisheranalyse
    - ocdskingfisherarchiveonarchive
    - prometheus-client-apache

  'cove-live*':
    - cove
    - prometheus-client-apache

  'kingfisher-process*':
    - postgres11
    - ocdskingfisher
    - ocdskingfisherarchiveonprocess
    - ocdskingfisherscrape
    - ocdskingfisherprocess
    - ocdskingfisheranalyse
    - prometheus-client-apache

  'prometheus':
    - prometheus-client-apache
    - prometheus-server
