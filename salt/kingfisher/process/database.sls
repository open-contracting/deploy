# Groups
# https://wiki.postgresql.org/images/d/d1/Managing_rights_in_postgresql.pdf

read_kingfisher_process:
  postgres_group.present:
    - name: read_kingfisher_process
    - require:
      - service: postgresql

read_kingfisher_summarize:
  postgres_group.present:
    - name: read_kingfisher_summarize
    - require:
      - service: postgresql

# Users

ocdskfp:
  postgres_user.present:
    - name: ocdskfp
    - password: {{ pillar.postgres.ocdskfp.password }}
    - require:
      - service: postgresql

# Databases

ocdskingfisherprocess:
  postgres_database.present:
    - name: ocdskingfisherprocess
    - owner: ocdskfp
    - require:
      - postgres_user: ocdskfp

# Extensions

# https://github.com/open-contracting/deploy/issues/117
# https://github.com/open-contracting/deploy/issues/237
{% set extensions = ['tablefunc', 'fuzzystrmatch', 'pg_trgm'] %}

{% for extension in extensions %}
{{ extension }}:
  postgres_extension.present:
    - name: {{ extension }}
    - if_not_exists: True
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess
{% endfor %}

# Schemas

reference:
  postgres_schema.present:
    - name: reference
    - user: ocdskfp
    - dbname: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess

# REVOKE privileges
# https://www.postgresql.org/docs/11/sql-revoke.html

revoke public schema privileges:
  postgres_privileges.absent:
    - name: public
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess

# GRANT privileges
# https://www.postgresql.org/docs/11/sql-grant.html
# https://www.postgresql.org/docs/11/ddl-priv.html

# https://kingfisher-process.readthedocs.io/en/latest/requirements-install.html#database
grant ocdskfp schema privileges:
  postgres_privileges.present:
    - name: ocdskfp
    - privileges:
      - CREATE
    - object_type: schema
    - object_name: public
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_user: ocdskfp
      - postgres_database: ocdskingfisherprocess

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
      - postgres_user: kingfisher_summarize
      - postgres_database: ocdskingfisherprocess

{% set schemas = {'public': 'read_kingfisher_process', 'reference': 'read_kingfisher_summarize'} %}

{% for schema, group in schemas.items() %}
grant {{ group }} schema privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - USAGE
    - object_type: schema
    - object_name: {{ schema }}
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess

grant {{ group }} table privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - SELECT
    - object_type: table
    - object_name: ALL
    - prepend: {{ schema }}
    - maintenance_db: ocdskingfisherprocess
    - require:
      - postgres_database: ocdskingfisherprocess

/opt/{{ group }}-{{ schema }}.sql:
  file.managed:
    - name: /opt/{{ group }}-{{ schema }}.sql
    - contents: "ALTER DEFAULT PRIVILEGES FOR ROLE ocdskfp IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ group }};"

# Can replace after `postgres_default_privileges` function becomes available.
# https://github.com/saltstack/salt/pull/56808
alter {{ group }} default privileges in {{ schema }}:
  cmd.run:
    - name: psql -f /opt/{{ group }}-{{ schema }}.sql ocdskingfisherprocess
    - runas: ocdskfp
    - onchanges:
      - file: /opt/{{ group }}-{{ schema }}.sql
    - require:
      - postgres_group: {{ group }}
      - postgres_database: ocdskingfisherprocess
{% endfor %}
