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

  'covid19*':
    - covid19
    - private.covid19

  'covid19':
    - covid19_prod
    - private.covid19_prod
    - covid19_maintenance

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
    - maintenance

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
