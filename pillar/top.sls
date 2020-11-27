# Defines which pillars should be used for each target. Each target has a public and private pillar.

base:
  '*':
    - common
    - private.common
    - private.prometheus

  'cove-oc4ids':
    - django
    - cove
    - cove_oc4ids
    - private.cove_oc4ids
    - maintenance_simple

  'cove-ocds':
    - django
    - cove
    - cove_ocds
    - private.cove_ocds
    - maintenance_simple

  'docs':
    - docs
    - tinyproxy
    - docs_maintenance

  'kingfisher-process':
    - kingfisher
    - private.kingfisher
    - tinyproxy
    - kingfisher_process_maintenance

  'kingfisher-replica':
    - kingfisher_replica
    - kingfisher_replica_maintenance

  'prometheus':
    - maintenance_simple

  'redash':
    - redash
    - maintenance_simple

  'toucan':
    - django
    - toucan
    - private.toucan
    - maintenance_simple
