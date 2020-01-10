# Defines which pillars should be used for each target. Each target has a public and private pillar.

base:
  '*':
    - common_pillar
    - private.prometheus_pillar

  'ocds-docs-live':
    - ocds_docs_live_pillar

  'ocds-docs-staging':
    - ocds_docs_staging_pillar
    - tinyproxy_pillar

  'standard-search':
    - django_pillar
    - standard_search_pillar
    - private.standard_search_pillar

  'toucan':
    - django_pillar
    - toucan_pillar
    - private.toucan_pillar

  'ocds-kingfisher-archive':
    - ocdskingfisher_archive_live_pillar

  'cove-live-oc4ids':
    - django_pillar
    - cove_pillar
    - cove_oc4ids_live_pillar
    - private.cove_oc4ids_live_pillar

  'cove-live-ocds-2':
    - django_pillar
    - cove_pillar
    - cove_ocds_live_pillar
    - private.cove_ocds_live_pillar

  'kingfisher-process*':
    - ocdskingfisher_live_pillar
    - private.ocdskingfisher_live_pillar
    - private.ocdskingfisher_pillar
    - tinyproxy_pillar
