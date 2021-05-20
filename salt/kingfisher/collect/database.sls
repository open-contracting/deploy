# See salt/kingfisher/process/database.sls

# Groups

kingfisher_collect_read:
  postgres_group.present:
    - name: kingfisher_collect_read
    - require:
      - service: postgresql

# Databases

ocdskingfishercollect:
  postgres_database.present:
    - name: ocdskingfishercollect
    - owner: postgres
    - require:
      - service: postgresql

# REVOKE privileges

revoke public schema privileges:
  postgres_privileges.absent:
    - name: public
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: ocdskingfishercollect
    - require:
      - postgres_database: ocdskingfishercollect

# GRANT privileges

grant kingfisher_collect schema privileges:
  postgres_privileges.present:
    - name: kingfisher_collect
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: ocdskingfishercollect
    - require:
      - postgres_user: sql-user-kingfisher_collect
      - postgres_database: ocdskingfishercollect

{% set schema_groups = {'public': ['kingfisher_collect_read']} %}

{% for schema, groups in schema_groups.items() %}
{% for group in groups %}
grant {{ group }} schema privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - USAGE
    - object_type: schema
    - object_name: {{ schema }}
    - maintenance_db: ocdskingfishercollect
    - require:
      - postgres_database: ocdskingfishercollect

grant {{ group }} table privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - SELECT
    - object_type: table
    - object_name: ALL
    - prepend: {{ schema }}
    - maintenance_db: ocdskingfishercollect
    - require:
      - postgres_database: ocdskingfishercollect

/opt/{{ group }}-{{ schema }}.sql:
  file.managed:
    - name: /opt/{{ group }}-{{ schema }}.sql
    - contents: "ALTER DEFAULT PRIVILEGES FOR ROLE kingfisher_collect IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ group }};"

# Can replace after `postgres_default_privileges` function becomes available.
# https://github.com/saltstack/salt/pull/56808
alter {{ group }} default privileges in {{ schema }}:
  cmd.run:
    - name: psql -f /opt/{{ group }}-{{ schema }}.sql ocdskingfishercollect
    - runas: postgres
    - onchanges:
      - file: /opt/{{ group }}-{{ schema }}.sql
    - require:
      - postgres_database: ocdskingfishercollect
{% endfor %}
{% endfor %}
