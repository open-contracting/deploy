# Defines which pillars should be used for each target.

base:
  '*':
    - common
    - private.common

  'coalition':
    - coalition
    - private.coalition

  'cove-oc4ids':
    - cove
    - cove_oc4ids
    - cove_oc4ids_maintenance
    - private.cove_oc4ids

  'cove-ocds':
    - cove
    - cove_ocds
    - cove_ocds_maintenance
    - private.cove_ocds

  'credere':
    - credere
    - credere_dev
    - private.credere

  'docs':
    - docs
    - private.docs
    - tinyproxy
    - docs_maintenance

  'kingfisher-process':
    - kingfisher_common
    - kingfisher_process
    - private.kingfisher_common
    - private.kingfisher_process
    - tinyproxy
    - kingfisher_process_maintenance

  'kingfisher-replica':
    - kingfisher_common
    - kingfisher_replica
    - private.kingfisher_common
    - kingfisher_replica_maintenance

  'prometheus':
    - prometheus_server
    - private.smtp
    - private.prometheus_server
    - prometheus_server_maintenance

  'redash':
    - redash
    - private.redash
    - redash_maintenance

  'redmine':
    - redmine
    - private.redmine
    - redmine_maintenance

  'registry':
    - registry
    - private.registry
    - registry_maintenance

  # Don't install the Prometheus Node Exporter on development or test servers.
  '* and not G@id:*-dev and not G@id:*-test':
    - prometheus_client
    - private.prometheus_client
