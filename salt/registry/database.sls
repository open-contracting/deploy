{% from 'lib.sls' import create_pg_database, create_pg_groups, create_pg_privileges %}

{% for user in ['data_registry', 'kingfisher_process', 'pelican'] %}
{{ create_pg_database(user, user) }}
{% endfor %}

{{ create_pg_groups(['kingfisher_process_read']) }}

{{ create_pg_privileges('kingfisher_process', 'kingfisher_process', {'public': ['kingfisher_process_read']}) }}
