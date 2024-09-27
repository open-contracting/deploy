{% from 'lib.sls' import apache, set_firewall, unset_firewall %}

{% if pillar.netdata.enabled or 'ssl' in pillar.postgres %}
include:
{% if pillar.netdata.enabled %}
  - postgres.netdata
{% endif %}
{% if 'ssl' in pillar.postgres %}
  - apache
{% endif %}
{% endif %}

{% if pillar.postgres.get('public_access') %}
  {{ set_firewall('PUBLIC_POSTGRESQL') }}
  {{ unset_firewall('PRIVATE_POSTGRESQL') }}
  {{ unset_firewall('REPLICA_IPV4') }}
  {{ unset_firewall('REPLICA_IPV6') }}
{% else %}
  {{ unset_firewall('PUBLIC_POSTGRESQL') }}
  {{ set_firewall('PRIVATE_POSTGRESQL') }}
  {% if 'replica_ipv4' in pillar.postgres %}
    {{ set_firewall('REPLICA_IPV4', pillar.postgres.replica_ipv4|join(' ')) }}
  {% endif %}
  {% if 'replica_ipv6' in pillar.postgres %}
    {{ set_firewall('REPLICA_IPV6', pillar.postgres.replica_ipv6|join(' ')) }}
  {% endif %}
  {% if salt['pillar.get']('maintenance:enabled') %}
    {{ set_firewall('MONITOR_APPBEAT') }}
  {% endif %}
{% endif %}

postgres_authorized_keys:
  ssh_auth.manage:
    - user: postgres
    - ssh_keys: {{ salt['pillar.get']('ssh:postgres', [])|yaml }}
    - require:
      - pkg: postgresql

{% if 'ssh_key' in pillar.postgres %}
/var/lib/postgresql/.ssh:
  file.directory:
    - user: postgres
    - group: postgres
    - makedirs: True
    - mode: 700
    - require:
      - pkg: postgresql

/var/lib/postgresql/.ssh/id_rsa:
  file.managed:
    - contents_pillar: postgres:ssh_key
    - user: postgres
    - group: postgres
    - mode: 600
    - require:
      - pkg: postgresql
{% endif %}

# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
# https://github.com/jfcoz/postgresqltuner
vm.overcommit_memory:
  sysctl.present:
    - value: {{ salt['pillar.get']('vm:overcommit_memory', 2) }}

# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES
# https://github.com/jfcoz/postgresqltuner
{% if salt['pillar.get']('vm:nr_hugepages') %}
vm.nr_hugepages:
  sysctl.present:
    - value: {{ pillar.vm.nr_hugepages }}
{% endif %}

pgbadger:
  pkg.installed:
    - name: pgbadger

/var/lib/postgresql/postgresqltuner.pl:
  pkg.installed:
    - pkgs:
      - libdbd-pg-perl
      - libdbi-perl
  file.managed:
    - source: https://raw.githubusercontent.com/jfcoz/postgresqltuner/master/postgresqltuner.pl
    # curl -sS https://raw.githubusercontent.com/jfcoz/postgresqltuner/master/postgresqltuner.pl | shasum -a 256
    - source_hash: 3b5d389c4997c2e4d05f6fc22ac60ab60d55aad65df6d157b18445af3a6c7a31
    - mode: 755

postgresql:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    {% if grains.osmajorrelease | string in ('18', '20') %}
    - name: deb https://apt.postgresql.org/pub/repos/apt {{ grains.oscodename }}-pgdg main
    {% else %}
    - name: deb [signed-by=/usr/share/keyrings/postgresql-keyring.gpg] https://apt.postgresql.org/pub/repos/apt {{ grains.oscodename }}-pgdg main
    - aptkey: False
    {% endif %}
    - dist: {{ grains.oscodename }}-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
  pkg.installed:
    - name: postgresql-{{ pillar.postgres.version }}
    - require:
      - pkgrepo: postgresql
  service.running:
    # The "postgresql" service is a dummy service, and causes the service status to be misreported.
    - name: postgresql@{{ pillar.postgres.version }}-main.service
    - enable: True
    - require:
      - pkg: postgresql

postgresql-reload:
  module.wait:
    - name: service.reload
    - m_name: postgresql@{{ pillar.postgres.version }}-main.service

/etc/postgresql/{{ pillar.postgres.version }}/main/pg_hba.conf:
  file.managed:
    - source: salt://postgres/files/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - pkg: postgresql
    - watch_in:
      - module: postgresql-reload

{% if 'ssl' in pillar.postgres %}
/etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem:
  file.copy:
    - source: /etc/ssl/certs/ssl-cert-snakeoil.pem
    - user: postgres
    - group: postgres
    - mode: 600
    - require:
      - pkg: postgresql

/etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem:
  file.copy:
    - source: /etc/ssl/private/ssl-cert-snakeoil.key
    - user: postgres
    - group: postgres
    - mode: 600
    - require:
      - pkg: postgresql

/etc/postgresql/{{ pillar.postgres.version }}/main/postgresql.conf:
  file.keyvalue:
    - key_values:
        ssl_cert_file: "'/etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem'"
        ssl_key_file: "'/etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem'"
        # Default is '%m [%p] %q%u@%d ' in /etc/postgresql/15/main/postgresql.conf.
        log_line_prefix: "'%h %m [%p] %q%u@%d '"
    - separator: ' = '
    - uncomment: '#'
    # Copy the self-signed certificate into place, so that PostgreSQL can start.
    - require:
      - file: /etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem
      - file: /etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem
    - watch_in:
      - service: postgresql

/opt/postgresql-certificates.sh:
  file.managed:
    - name: /opt/postgresql-certificates.sh
    - source: salt://postgres/files/postgresql-certificates.sh
    - template: jinja
    - mode: 755

{{ apache('postgres', {'configuration': 'default', 'servername': pillar.postgres.ssl.servername}) }}
{% endif %}

{% if pillar.postgres.configuration %}
/etc/postgresql/{{ pillar.postgres.version }}/main/conf.d/030_{{ pillar.postgres.configuration.name }}.conf:
  file.managed:
    - source: salt://postgres/files/conf/{{ pillar.postgres.configuration.source }}.conf
    - template: jinja
    - context: {{ pillar.postgres.configuration.context|yaml }}
    - user: postgres
    - group: postgres
    - mode: 640
    - require:
      - pkg: postgresql
    - watch_in:
      - service: postgresql
{% if salt['pillar.get']('postgres:backup:stanza') %}
    - require:
      - sls: postgres.backup
{% endif %}
{% endif %}

# https://github.com/jfcoz/postgresqltuner
pg_stat_statements:
  postgres_extension.present:
    - maintenance_db: template1
    - if_not_exists: True

# If not replication, create groups, users, databases, schemas and privileges.
{% if not pillar.postgres.get('replication') %}
# https://wiki.postgresql.org/images/d/d1/Managing_rights_in_postgresql.pdf

{% for name in pillar.postgres.groups|default([]) %}
{{ name }}_sql_group:
  postgres_group.present:
    - name: {{ name }}
    - require:
      - service: postgresql
{% endfor %} {# groups #}

{% for name, entry in pillar.postgres.users|items %}
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
{% for group in entry.groups|default([]) %}
      - postgres_group: {{ group }}_sql_group
{% endfor %}
{% endfor %} {# users #}

{% for database, entry in pillar.postgres.databases|items %}
{{ database }}_sql_database:
  postgres_database.present:
    - name: {{ database }}
    - owner: postgres
    - require:
      - service: postgresql

# REVOKE all schema privileges from the public role
# https://www.postgresql.org/docs/current/sql-revoke.html
revoke public schema privileges on {{ database }} database:
  postgres_privileges.absent:
    - name: public
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}_sql_database

# GRANT all schema privileges to the owner
# Note: These states always report changes.
# https://www.postgresql.org/docs/current/sql-grant.html
# https://www.postgresql.org/docs/current/ddl-priv.html
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
      - postgres_database: {{ database }}_sql_database

{% for schema, owner in entry.schemas|items %}
{{ schema }}_sql_schema:
  postgres_schema.present:
    - name: {{ schema }}
    - owner: {{ owner.name }}
    - dbname: {{ database }}
    - require:
      - postgres_{{ owner.type }}: {{ owner.name }}_sql_{{ owner.type }}
      - postgres_database: {{ database }}_sql_database
{% endfor %} {# schemas #}

{% for schema, roles in entry.privileges|items %}
{% for role, tables in roles|items %}
{% if tables %}
{% for table in tables %}
# GRANT the SELECT privilege on selected tables in the schema to the role
grant {{ role }} table privileges to {{ table }} in {{ schema }}:
  postgres_privileges.present:
    - name: {{ role }}
    - privileges:
      - SELECT
    - object_type: table
    - object_name: {{ table }}
    - prepend: {{ schema }}
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}_sql_database
  {% if schema != 'public' %}
      - postgres_schema: {{ schema }}_sql_schema
  {% endif %}
{% endfor %}
{% else %}
# GRANT the USAGE privilege on the schema to the role
grant {{ role }} schema privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ role }}
    - privileges:
      - USAGE
    - object_type: schema
    - object_name: {{ schema }}
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}_sql_database
  {% if schema != 'public' %}
      - postgres_schema: {{ schema }}_sql_schema
  {% endif %}

# GRANT the SELECT privilege on all tables in the schema to the role
grant {{ role }} table privileges in {{ schema }}:
  postgres_privileges.present:
    - name: {{ role }}
    - privileges:
      - SELECT
    - object_type: table
    - object_name: ALL
    - prepend: {{ schema }}
    - maintenance_db: {{ database }}
    - require:
      - postgres_database: {{ database }}_sql_database
  {% if schema != 'public' %}
      - postgres_schema: {{ schema }}_sql_schema
  {% endif %}

/opt/default-privileges/{{ role }}-{{ schema }}.sql:
  file.managed:
    - name: /opt/default-privileges/{{ role }}-{{ schema }}.sql
    - contents: "ALTER DEFAULT PRIVILEGES FOR ROLE {{ entry.user }} IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ role }};"
    - makedirs: True

# ALTER default privileges such that, when the user creates a table in the schema, the SELECT privilege is granted to the role.
# Can replace after `postgres_default_privileges` function becomes available. https://github.com/saltstack/salt/pull/56808
alter {{ role }} default privileges in {{ schema }}:
  cmd.run:
    - name: psql -v ON_ERROR_STOP=1 -f /opt/default-privileges/{{ role }}-{{ schema }}.sql {{ database }}
    - runas: postgres
    - require:
      - postgres_database: {{ database }}_sql_database
  {% if schema != 'public' %}
      - postgres_schema: {{ schema }}_sql_schema
  {% endif %}
    - onchanges:
      - file: /opt/default-privileges/{{ role }}-{{ schema }}.sql
      # If a database is re-created, re-run the default privileges statement.
      - postgres_database: {{ database }}_sql_database
{% endif %}
{% endfor %}
{% endfor %} {# privileges #}

{% endfor %} {# databases #}

{% endif %} {# not replication #}
