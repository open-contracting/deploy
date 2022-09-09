{% set mysql_version = pillar.mysql.get('version', '8.0') %}

mysql install dependencies:
  pkg.installed:
    - pkgs:
      - gnupg2
      - python3-mysqldb

{# Using Percona's offical tool "percona-release" to configure their repositories and signing keys. #}
percona-release:
  pkg.installed:
    - name: percona-release
    - sources:
      - percona-release: https://repo.percona.com/apt/percona-release_latest.{{ salt['grains.get']('lsb_distrib_codename') }}_all.deb
  cmd.run:
    - name: percona-release setup ps{{ mysql_version|replace('.', '') }}
    - creates: /etc/apt/sources.list.d/percona-ps-80-release.list
    - require:
      - pkg: percona-release

percona-mysql:
  pkg.installed:
    - name: percona-server-server
    - require:
      - pkg: percona-release
  service.running:
    - name: mysql
    - enable: True
    - require:
      - pkg: percona-mysql

remove test database:
  mysql_database.absent:
    - name: test
    - require:
      - service: mysql

/etc/mysql/conf.d/defaults.cnf:
  file.managed:
    - source: salt://mysql/files/defaults.cnf
    - watch_in:
      - service: mysql

{% if pillar.mysql.get('configuration') %}
/etc/mysql/conf.d/{{ pillar.mysql.configuration }}.cnf:
  file.managed:
    - source: salt://mysql/files/conf/{{ pillar.mysql.configuration }}.cnf
    - watch_in:
      - service: mysql
{% endif %} {# config #}

{% if pillar.mysql.get('users') %}
{% for name, entry in pillar.mysql.users.items() %}
{{ name }}_mysql_user:
  mysql_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
    - require:
      - service: mysql
{% endfor %}
{% endif %} {# users #}

{% if pillar.mysql.get('databases') %}
{% for database, entry in pillar.mysql.databases.items() %}
{{ database }}:
  mysql_database.present:
    - name: {{ database }}
    - require:
      - service: mysql

grant {{ entry.user }} privileges:
  mysql_grants.present:
    - grant: all privileges
    - database: {{ database }}.*
    - user: {{ entry.user }}
    - require:
      - mysql_user: {{ entry.user }}_mysql_user
      - mysql_database: {{ database }}
{% endfor %}
{% endif %} {# databases #}
