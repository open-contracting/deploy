# Defines common macros.

{% macro set_firewall(setting_name, setting_value="yes") %}
set {{ setting_name }} firewall setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/firewall-settings.local
    - key: {{ setting_name }}
    - value: '"{{ setting_value }}"'
    - append_if_not_found: True
{% endmacro %}

{% macro unset_firewall(setting_name) %}
unset {{ setting_name }} firewall setting:
  file.keyvalue:
    - name: /home/sysadmin-tools/firewall-settings.local
    - key: {{ setting_name }}
    - value: '""'
    - ignore_if_missing: True
{% endmacro %}

# It is safe to use `[]` as a default value, because the default value is never mutated.
{% macro create_user(user, authorized_keys=[]) %}
{{ user }}_user_exists:
  user.present:
    - name: {{ user }}
    - home: /home/{{ user }}
    - order: 1
    - shell: /bin/bash

{{ user }}_authorized_keys:
  ssh_auth.manage:
    - user: {{ user }}
    - ssh_keys: {{ (pillar.ssh.admin + salt['pillar.get']('ssh:root', []) + authorized_keys)|yaml }}
    - require:
      - user: {{ user }}_user_exists
{% endmacro %}

{#
  Accepts an `entry` object with a `service` key for the name of the service, a `user` key for the user to run the
  service, and any other keys to be passed to the `*.service` template.
#}
# https://www.freedesktop.org/software/systemd/man/systemd.directives.html
{% macro systemd(entry) %}
/etc/systemd/system/{{ entry.service }}.service:
  file.managed:
    - source: salt://core/systemd/files/{{ entry.service }}.service
    - template: jinja
    - context:
        user: {{ entry.user }}
        entry: {{ entry|yaml }}
    - watch_in:
      - service: {{ entry.service }}

{{ entry.service }}:
  service.running:
    - enable: True
    - require:
      - file: /etc/systemd/system/{{ entry.service }}.service

{{ entry.service }}-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ entry.service }}
{% endmacro %}

{#
  Accepts a `name` string used to name configuration files, an `entry` object with Apache configuration, and a
  `context` object, whose keys are made available as variables in the configuration template.

  See https://ocdsdeploy.readthedocs.io/en/latest/develop/update/apache.html
#}
# It is safe to use `{}` as a default value, because the default value is never mutated.
{% macro apache(name, entry, context={}) %}
{% if 'ipv4' in pillar.apache %}
/etc/apache2/ports.conf:
  file.managed:
    - source: salt://apache/files/ports.conf
    - template: jinja
    - require:
      - pkg: apache2
    - watch_in:
      - service: apache2
{% endif %}

/etc/apache2/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://apache/files/sites/{{ entry.configuration }}.conf.include
    - template: jinja
    - context: {{ dict(context, name=name, **entry.get('context', {}))|yaml }}
    - require:
      - pkg: apache2
    - watch_in:
      - module: apache2-reload

/etc/apache2/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/files/sites/_common.conf
    - template: jinja
    - context:
        includefile: /etc/apache2/sites-available/{{ name }}.conf.include
        servername: {{ entry.servername }}
        serveraliases: {{ entry.get('serveraliases', [])|yaml }}
        https: {{ entry.get('https', True) }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
    - watch_in:
      - module: apache2-reload

enable site {{ name }}.conf:
  apache_site.enabled:
    - name: {{ name }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf
    - watch_in:
      - module: apache2-reload

{% if 'htpasswd' in entry %}
add .htpasswd-{{ name }}:
  webutil.user_exists:
    - name: {{ entry.htpasswd.name }}
    - password: {{ entry.htpasswd.password }}
    - htpasswd_file: /etc/apache2/.htpasswd-{{ name }}
    - update: True
    - require:
      - pkg: apache2
{% endif %}
{% endmacro %}

{#
  Creates the database, revokes all schema privileges from the public role, and grants all schema privileges to the user.
#}
# https://wiki.postgresql.org/images/d/d1/Managing_rights_in_postgresql.pdf

{% macro create_pg_database(database, user) %}
{{ database }}:
  postgres_database.present:
    - name: {{ database }}
    - owner: postgres
    - require:
      - service: postgresql

# REVOKE privileges
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

# GRANT privileges
# https://www.postgresql.org/docs/11/sql-grant.html
# https://www.postgresql.org/docs/11/ddl-priv.html

grant {{ user }} schema privileges:
  postgres_privileges.present:
    - name: {{ user }}
    - privileges:
      - ALL
    - object_type: schema
    - object_name: public
    - maintenance_db: {{ database }}
    - require:
      - postgres_user: {{ user }}_sql_user
      - postgres_database: {{ database }}
{% endmacro %}

{#
  - Grants the USAGE privilege on the schema to the groups
  - Grants the SELECT privilege on all tables in the schema to the groups
  - Alters default privileges such that, when the user creates a table in the schema, the SELECT privilege is granted to the groups

  :param dict schema_groups: a dict in which the key is a schema, and the value is a list of groups.
#}
{% macro create_pg_privileges(database, user, schema_groups) %}
{% for schema, groups in schema_groups.items() %}
{% for group in groups %}
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

/opt/{{ group }}-{{ schema }}.sql:
  file.managed:
    - name: /opt/{{ group }}-{{ schema }}.sql
    - contents: "ALTER DEFAULT PRIVILEGES FOR ROLE {{ user }} IN SCHEMA {{ schema }} GRANT SELECT ON TABLES TO {{ group }};"

# Can replace after `postgres_default_privileges` function becomes available.
# https://github.com/saltstack/salt/pull/56808
alter {{ group }} default privileges in {{ schema }}:
  cmd.run:
    - name: psql -f /opt/{{ group }}-{{ schema }}.sql {{ database }}
    - runas: postgres
    - onchanges:
      - file: /opt/{{ group }}-{{ schema }}.sql
    - require:
      - postgres_database: {{ database }}
{% endfor %}
{% endfor %}
{% endmacro %}
