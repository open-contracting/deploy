{% from 'lib.sls' import create_pg_database, create_pg_privileges %}

kingfisher_collect_read:
  postgres_group.present:
    - name: kingfisher_collect_read
    - require:
      - service: postgresql

{{ create_pg_database('ocdskingfishercollect', 'kingfisher_collect') }}

{{ create_pg_privileges('ocdskingfishercollect', 'kingfisher_collect', {'public': ['kingfisher_collect_read']}) }}
