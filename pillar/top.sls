# Defines which pillars should be used for each target. Each target has a public and private pillar.

base:
  '*':
    - common
    - private.common
    - private.prometheus

  'ocds-docs-live':
    - ocds_docs_live
    - tinyproxy
    - ocds_docs_live_maintenance

  'standard-search':
    - django
    - standard_search
    - private.standard_search
    - standard-search_maintenance

  'toucan':
    - django
    - toucan
    - private.toucan
    - toucan_maintenance

  'cove-live-oc4ids':
    - django
    - cove
    - cove_oc4ids_live
    - private.cove_oc4ids_live
    - cove_oc4ids_live_maintenance

  'cove-live-ocds-3':
    - django
    - cove
    - cove_ocds_live3
    - private.cove_ocds_live
    - cove_ocds_live3_maintenance

  'kingfisher-process*':
    - ocdskingfisher_live
    - private.ocdskingfisher_live
    - tinyproxy

  'kingfisher-process1':
    - kingfisher_process1_maintenance

  'kingfisher-replica*':
    - ocdskingfisher_replica_live
    - ocdskingfisher_replica1_maintenance

  'prometheus':
    - prometheus_maintenance

  'redash2':
    - redash
    - redash2_maintenance
