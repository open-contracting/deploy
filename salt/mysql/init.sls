{% set mysql_version = pillar.mysql.version|default('8.0')|quote %}

# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.mysql_database.html
mysql dependencies:
  pkg.installed:
    - pkgs:
      - python3-mysqldb

{# Using Percona's official tool "percona-release" to configure their repositories and signing keys. #}
percona-release:
  pkg.installed:
    - name: percona-release
    - sources:
      - percona-release: https://repo.percona.com/apt/percona-release_latest.{{ salt['grains.get']('lsb_distrib_codename') }}_all.deb
  cmd.run:
    - name: percona-release setup ps{{ mysql_version|replace('.', '') }}
    - creates: /etc/apt/sources.list.d/percona-ps-{{ mysql_version|replace('.', '') }}-release.list
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
  debconf.set:
    - data:
        'percona-server-server/default-auth-override': { 'type' : 'select', 'value': 'Use Strong Password Encryption (RECOMMENDED)' }
    - require:
      - pkg: debconf-utils

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

{% if pillar.mysql.configuration %}
/etc/mysql/conf.d/{{ pillar.mysql.configuration }}.cnf:
  file.managed:
    - source: salt://mysql/files/conf/{{ pillar.mysql.configuration }}.cnf
    - watch_in:
      - service: mysql
{% endif %} {# config #}

{% for name, entry in pillar.mysql.users|items %}
{{ name }}_mysql_user:
  mysql_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
{% if 'host' in entry %}
    - host: "{{ entry.host }}"
{% endif %}
    - require:
      - service: mysql
{% endfor %} {# users #}

{% for database, entry in pillar.mysql.databases|items %}
{{ database }}_mysql_database:
  mysql_database.present:
    - name: {{ database }}
    - require:
      - service: mysql

grant {{ entry.user }} privileges:
  mysql_grants.present:
    - grant: all privileges
    - database: {{ database }}.*
    - user: {{ entry.user }}
{% if 'host' in entry %}
    - host: "{{ entry.host }}"
{% endif %}
    - require:
      - mysql_user: {{ entry.user }}_mysql_user
      - mysql_database: {{ database }}_mysql_database
{% endfor %} {# databases #}
