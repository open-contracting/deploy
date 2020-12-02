# Defines which pillars should be used for each target.

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
    - maintenance

  'cove-ocds':
    - django
    - cove
    - cove_ocds
    - private.cove_ocds
    - maintenance

  'covid19-dev':
    - covid19

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
    - maintenance

  'redash':
    - redash
    - maintenance

  'toucan':
    - django
    - toucan
    - private.toucan
    - maintenance
