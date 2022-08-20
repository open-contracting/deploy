{% from 'lib.sls' import set_firewall, unset_firewall %}

{% set pg_version = pillar.postgres.get('version', '11') %}

{% if pillar.postgres.get('public_access') %}
  {{ set_firewall("PUBLIC_POSTGRESQL") }}
  {{ unset_firewall("PRIVATE_POSTGRESQL") }}
  {{ unset_firewall("REPLICA_IPV4") }}
  {{ unset_firewall("REPLICA_IPV6") }}
{% else %}
  {{ unset_firewall("PUBLIC_POSTGRESQL") }}
  {{ set_firewall("PRIVATE_POSTGRESQL") }}
  {% if pillar.postgres.get('replica_ipv4') %}
    {{ set_firewall("REPLICA_IPV4", pillar.postgres.replica_ipv4|join(' ')) }}
  {% endif %}
  {% if pillar.postgres.get('replica_ipv6') %}
    {{ set_firewall("REPLICA_IPV6", pillar.postgres.replica_ipv6|join(' ')) }}
  {% endif %}
  {% if salt['pillar.get']('maintenance:enabled') %}
    {{ set_firewall("MONITOR_APPBEAT") }}
  {% endif %}
{% endif %}

postgresql:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb https://apt.postgresql.org/pub/repos/apt {{ grains.oscodename }}-pgdg main
    - dist: {{ grains.oscodename }}-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
  pkg.installed:
    - name: postgresql-{{ pg_version }}
    - require:
      - pkgrepo: postgresql
  service.running:
    # The "postgresql" service is a dummy service, and causes the service status to be misreported.
    - name: postgresql@{{ pg_version }}-main.service
    - enable: True
    - require:
      - pkg: postgresql

postgresql-reload:
  module.wait:
    - name: service.reload
    - m_name: postgresql@{{ pg_version }}-main.service

# Upload access configuration for postgres.
/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - source: salt://postgres/files/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 640
    - watch_in:
      - module: postgresql-reload

{% if pillar.postgres.configuration %}
# Although we can add `shared.include` as a separate file (e.g. looping over configurations, and using `loop.index0`
# to prefix the files), this makes changes harder to deploy, since re-ordering or removing a configuration will rename
# the new files, but not remove the old files. Instead, a developer needs to `include` it in the configuration file.
#
# (Unfortunately, `file.managed` doesn't have a `sources` option like `file.append` in order to create a target file
# from many source files, and `file.accumulated` doesn't have a `source` option.)
/etc/postgresql/{{ pg_version }}/main/conf.d/030_{{ pillar.postgres.configuration }}.conf:
  file.managed:
    - source: salt://postgres/files/conf/{{ pillar.postgres.configuration }}.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 640
    - watch_in:
      - service: postgresql
{% if salt['pillar.get']('postgres:backup:stanza') %}
    - require:
      - sls: postgres.backup
{% endif %}
{% endif %}

# https://www.postgresql.org/docs/11/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
# https://github.com/jfcoz/postgresqltuner
vm.overcommit_memory:
  sysctl.present:
    - value: {{ salt['pillar.get']('vm:overcommit_memory', 2) }}

# https://www.postgresql.org/docs/11/kernel-resources.html#LINUX-HUGE-PAGES
# https://github.com/jfcoz/postgresqltuner
{% if salt['pillar.get']('vm:nr_hugepages') %}
vm.nr_hugepages:
  sysctl.present:
    - value: {{ pillar.vm.nr_hugepages }}
{% endif %}

# https://github.com/jfcoz/postgresqltuner
pg_stat_statements:
  postgres_extension.present:
    - maintenance_db: template1
    - if_not_exists: True

{% if pillar.postgres.get('ssh_key') %}
/var/lib/postgresql/.ssh:
  file.directory:
    - makedirs: True
    - mode: 700

/var/lib/postgresql/.ssh/id_rsa:
  file.managed:
    - contents_pillar: postgres:ssh_key
    - mode: 600
{% endif %}

{% if not pillar.postgres.get('replication') %}
# https://wiki.postgresql.org/images/d/d1/Managing_rights_in_postgresql.pdf

{% if pillar.postgres.get('groups') %}
{% for name in pillar.postgres.groups %}
{{ name }}:
  postgres_group.present:
    - name: {{ name }}
    - require:
      - service: postgresql
{% endfor %}
{% endif %} {# groups #}

{% if pillar.postgres.get('users') %}
{% for name, entry in pillar.postgres.users.items() %}
{{ name }}_sql_user:
  postgres_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
{% if 'groups' in entry %}
    - groups: {{ entry.groups|yaml }}
{% endif %}
{% if entry.get('replication') %}
    - replication: True
{% endif %}
    - require:
      - service: postgresql
{% if 'groups' in entry %}
{% for group in entry.groups %}
      - postgres_group: {{ group }}
{% endfor %}
{% endif %}
{% endfor %}
{% endif %} {# users #}

{% if pillar.postgres.get('databases') %}
{% for database, entry in pillar.postgres.databases.items() %}
{{ database }}:
  postgres_database.present:
    - name: {{ database }}
    - owner: postgres
    - require:
      - service: postgresql

# REVOKE all schema privileges from the public role
# https://www.postgresql.org/docs/11/sql-revoke.html
revoke public schema privileges on {{ database }} database:
  postgres_privileges.absent:
    - name: public
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}

# GRANT all schema privileges to the user
# https://www.postgresql.org/docs/11/sql-grant.html
# https://www.postgresql.org/docs/11/ddl-priv.html
grant {{ entry.user }} schema privileges:
  postgres_privileges.present:
    - name: {{ entry.user }}
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: {{ database }}
    - require:
      - postgres_user: {{ entry.user }}_sql_user
      - postgres_database: {{ database }}

{% if entry.get('privileges') %}
{% for schema, groups in entry.privileges.items() %}
{% for group in groups %}
# GRANT the USAGE privilege on the schema to the group
grant {{ group }} schema privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - USAGE
    - object_type: schema
    - object_name: {{ schema }}
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}

# GRANT the SELECT privilege on all tables in the schema to the group
grant {{ group }} table privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ group }}
    - privileges:
      - SELECT
    - object_type: table
    - object_name: ALL
    - prepend: {{ schema }}
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}

/opt/default-privileges/{{ group }}-{{ schema }}.sql:
  file.managed:
    - name: /opt/default-privileges/{{ group }}-{{ schema }}.sql
    - contents: "ALTER DEFAULT PRIVILEGES FOR ROLE {{ entry.user }} IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ group }};"
    - makedirs: True

# ALTER default privileges such that, when the user creates a table in the schema, the SELECT privilege is granted to the group.
# Can replace after `postgres_default_privileges` function becomes available. https://github.com/saltstack/salt/pull/56808
alter {{ group }} default privileges in {{ schema }}:
  cmd.run:
    - name: psql -f /opt/default-privileges/{{ group }}-{{ schema }}.sql {{ database }}
    - runas: postgres
    - onchanges:
      - file: /opt/default-privileges/{{ group }}-{{ schema }}.sql
      - postgres_database: {{ database }}
    - require:
      - postgres_database: {{ database }}
{% endfor %}
{% endfor %}
{% endif %} {# privileges #}

{% endfor %}
{% endif %} {# databases #}

{% endif %} {# replication #}

# Manage authorized keys for postgres user
postgres_authorized_keys:
  ssh_auth.manage:
    - user: postgres
    - ssh_keys: {{ salt['pillar.get']('ssh:postgres', [])|yaml }}
