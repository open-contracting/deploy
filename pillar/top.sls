# Defines which pillars should be used for each target.

base:
  '*':
    - common
    - private.common

  'coalition':
    - coalition
    - coalition_maintenance
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

  'credere-production':
    - credere_common
    - credere_production
    - credere_production_maintenance
    - private.credere_production

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
    - dream_bi
    - dream_bi_maintenance

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
