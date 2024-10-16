# Defines which pillars should be used for each target.

base:
  '*':
    - common
    - private.common

  'coalition':
    - coalition
    - coalition_maintenance
    - private.coalition

  'cove':
    - cove
    - cove_maintenance
    - private.cove

  'credere':
    - credere_common
    - credere
    - credere_maintenance
    - private.credere

  'credere-dev':
    - credere_common
    - credere_dev
    - credere_dev_maintenance
    - private.credere_dev

  'docs':
    - docs
    - private.docs
    - tinyproxy
    - docs_maintenance

  'dream-bi':
    - dreambi
    - dreambi_maintenance
    - private.dreambi

  'kingfisher-main':
    - kingfisher_main
    - private.kingfisher_main
    - tinyproxy
    - kingfisher_main_maintenance

  'portland-dev':
    - portland_dev

  'prometheus':
    - prometheus_server
    - private.smtp
    - private.prometheus_server
    - prometheus_server_maintenance

  'registry':
    - registry
    - private.registry
    - tinyproxy
    - registry_maintenance

  # Don't install the Prometheus Node Exporter on development or test servers.
  '* and not G@id:*-dev and not G@id:*-test':
    - prometheus_client
    - private.prometheus_client
