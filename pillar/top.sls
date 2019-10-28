# This file defines what pillars should be used for our servers
# For each environment we have a public and a private pillar

base:
  '*':
     - common_pillar
     - private.common_pillar
     - private.prometheus_pillar

  'ocdskingfisher-new':
     - ocdskingfisher_live_pillar
     - private.ocdskingfisher_live_pillar
     - private.ocdskingfisher_pillar

  'ocds-docs-live':
     - live_pillar

  'ocds-docs-staging':
     - staging_pillar
     - private.ocdskingfisher_pillar # this is for the proxy config

  'standard-search':
     - live_pillar
     - private.standard_search_pillar

  'ocds-redash*':
     - live_pillar
     - private.ocds_redash_pillar

  'ocdskit-web':
     - live_pillar
     - ocdskit_web_pillar
     - private.toucan_pillar

  'ocds-kingfisher-archive':
     - live_pillar
     - ocdskingfisher_archive_live_pillar

  'cove-live-oc4ids':
     - live_pillar
     - cove_oc4ids_live_pillar
     - private.cove_oc4ids_live_pillar

  'cove-live-ocds-2':
     - live_pillar
     - cove_ocds_live_pillar
     - private.cove_ocds_live_pillar


