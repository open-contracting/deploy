# Defines which pillars should be used for each target.

base:
  '*':
    - common
    - private.common

  'cms':
    - cms
    - cms_maintenance
    - coalition
    - digitalbuying
    - private.cms
    - private.coalition
    - private.digitalbuying
    - docker

  'cove':
    - cove
    - cove_maintenance
    - private.cove
    - docker

  'credere':
    - credere_common
    - credere
    - credere_maintenance
    - private.credere
    - docker

  'docs':
    - docs
    - docs_maintenance
    - private.docs
    - tinyproxy

  'dream-bi':
    - dreambi
    - dreambi_maintenance
    - private.dreambi
    - docker

  'kingfisher-main':
    - kingfisher_main
    - kingfisher_main_maintenance
    - private.kingfisher_main
    - tinyproxy
    - docker

  'portland-dev':
    - portland_dev
    - docker
    - private.smtp

  'prometheus':
    - prometheus_server
    - prometheus_server_maintenance
    - private.prometheus_server
    - private.smtp

  'registry':
    - registry
    - registry_maintenance
    - private.registry
    - tinyproxy
    - docker

  # Don't install the Prometheus Node Exporter on development or test servers.
  '* and not G@id:*-dev and not G@id:*-test':
    - prometheus_client
    - private.prometheus_client
