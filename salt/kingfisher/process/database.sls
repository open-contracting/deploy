# https://kingfisher-process.readthedocs.io/en/latest/requirements-install.html#database
{% from 'lib.sls' import create_pg_database, create_pg_groups, create_pg_privileges %}

{{ create_pg_database('ocdskingfisherprocess', 'kingfisher_process') }}

{{ create_pg_groups(['reference', 'kingfisher_process_read', 'kingfisher_summarize_read']) }}

# Extensions

# https://github.com/open-contracting/deploy/issues/117 for analysts to create pivot tables.
# https://github.com/open-contracting/deploy/issues/237 for analysts to match similar strings.
{% for extension in ['tablefunc', 'fuzzystrmatch', 'pg_trgm'] %}
{{ extension }}:
  postgres_extension.present:
    - name: {{ extension }}
    - if_not_exists: True
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess
{% endfor %}

# Schemas
# Kingfisher Summarize will create the `summaries` schema, using the privilege in the next section.

create reference schema:
  postgres_schema.present:
    - name: reference
    - owner: reference
    - dbname: ocdskingfisherprocess
    - require:
      - postgres_group: reference
      - postgres_database: ocdskingfisherprocess

# GRANT privileges
# Kingfisher Summarize will grant access to `view_data_*` schemas to the `kingfisher_summarize_read` group.

# "The database user must have the CREATE privilege on the database used by Kingfisher Process."
# https://kingfisher-summarize.readthedocs.io/en/latest/get-started.html#database
grant kingfisher_summarize database privileges:
  postgres_privileges.present:
    - name: kingfisher_summarize
    - privileges:
      - CREATE
    - object_type: database
    - object_name: ocdskingfisherprocess
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_user: sql-user-kingfisher_summarize
      - postgres_database: ocdskingfisherprocess

{{
  create_pg_privileges('ocdskingfisherprocess', 'kingfisher_process', {
    'reference': ['public'],
    'summaries': ['kingfisher_summarize_read'],
    'public': ['kingfisher_process_read'],
  })
}}
