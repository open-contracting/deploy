# See salt/kingfisher/process/database.sls
{% from 'lib.sls' import create_pg_database, create_pg_groups, create_pg_privileges %}

{{ create_pg_database('ocdskingfishercollect', 'kingfisher_collect') }}

{{ create_pg_groups(['kingfisher_collect_read']) }}

{{ create_pg_privileges('ocdskingfishercollect', 'kingfisher_collect', {'public': ['kingfisher_collect_read']}) }}
