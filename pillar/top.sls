# Defines which pillars should be used for each target. Each target has a public and private pillar.

base:
  '*':
     - common_pillar
     - private.prometheus_pillar

  'ocdskingfisher-new':
     - ocdskingfisher_live_pillar
     - private.ocdskingfisher_live_pillar
     - private.ocdskingfisher_pillar

  'ocds-docs-live':
     - ocds_docs_live_pillar

  'ocds-docs-staging':
     - ocds_docs_staging_pillar
     - private.ocdskingfisher_pillar # this is for the proxy config

  'standard-search':
     - private.standard_search_pillar

  'toucan':
     - toucan_pillar
     - private.toucan_pillar

  'ocds-kingfisher-archive':
     - ocdskingfisher_archive_live_pillar

  'cove-live-oc4ids':
     - cove_oc4ids_live_pillar
     - private.cove_oc4ids_live_pillar

  'cove-live-ocds-2':
     - cove_ocds_live_pillar
     - private.cove_ocds_live_pillar


