# Defines which pillars should be used for each target.

base:
  '*':
    - common
    - private.common

  'cove-oc4ids':
    - cove
    - cove_oc4ids
    - private.cove_oc4ids
    - maintenance

  'cove-ocds':
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
    - prometheus_server
    - private.prometheus_server
    - maintenance

  'redash':
    - redash
    - maintenance

  'toucan':
    - toucan
    - private.toucan
    - maintenance

  # This avoids having to repeat these states for all but one target.
  '* and not G@id:*-dev':
    - prometheus_client
    - private.prometheus_client
