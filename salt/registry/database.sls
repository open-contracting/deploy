{% from 'lib.sls' import create_pg_database, create_pg_privileges %}

kingfisher_process_read:
  postgres_group.present:
    - name: kingfisher_process_read
    - require:
      - service: postgresql

{% for user in ['data_registry', 'kingfisher_process', 'pelican'] %}
{{ create_pg_database(user, user) }}
{% endfor %}

{{ create_pg_privileges('kingfisher_process', 'kingfisher_process', {'public': ['kingfisher_process_read']}) }}
