# Defines which pillars should be used for each target. Each target has a public and private pillar.

base:
  '*':
    - common_pillar
    - private.prometheus_pillar

  'ocds-docs-live':
    - ocds_docs_live_pillar
    - tinyproxy_pillar
    - ocds_docs_live_maintenance

  'standard-search':
    - django_pillar
    - standard_search_pillar
    - private.standard_search_pillar
    - standard-search_maintenance

  'toucan':
    - django_pillar
    - toucan_pillar
    - private.toucan_pillar
    - toucan_maintenance

  'cove-live-oc4ids':
    - django_pillar
    - cove_pillar
    - cove_oc4ids_live_pillar
    - private.cove_oc4ids_live_pillar
    - cove_oc4ids_live_maintenance

  'cove-live-ocds-3':
    - django_pillar
    - cove_pillar
    - cove_ocds_live3_pillar
    - private.cove_ocds_live_pillar
    - cove_ocds_live3_maintenance

  'kingfisher-process*':
    - ocdskingfisher_live_pillar
    - private.ocdskingfisher_live_pillar
    - tinyproxy_pillar

  'kingfisher-process1':
    - kingfisher_process1_maintenance

  'kingfisher-replica*':
    - ocdskingfisher_replica_live_pillar
    - ocdskingfisher_replica1_maintenance

  'prometheus':
    - prometheus_maintenance

  'redash2':
    - redash
    - redash2_maintenance
