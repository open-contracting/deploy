{% from 'lib.sls' import set_firewall %}

{% set pg_version = salt['pillar.get']('postgres:version', '11') %}

{% if salt['pillar.get']('postgres:public_access') %}
{{ set_firewall("PUBLIC_POSTGRESQL") }}
{% else %}
{{ set_firewall("PRIVATE_POSTGRESQL") }}
  {% if salt['pillar.get']('postgres:replica_ipv4') %}
{{ set_firewall("ALLOW_IPV4", pillar.postgres.replica_ipv4|join(' ')) }}
  {% endif %}
  {% if salt['pillar.get']('postgres:replica_ipv6') %}
{{ set_firewall("ALLOW_IPV6", pillar.postgres.replica_ipv6|join(' ')) }}
  {% endif %}
{% endif %}

# Install PostgreSQL from the official repository, as it offers newer versions than the Ubuntu repository.
postgresql:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb https://apt.postgresql.org/pub/repos/apt/ {{ grains['oscodename'] }}-pgdg main
    - dist: {{ grains['oscodename'] }}-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
  pkg.installed:
    - name: postgresql-{{ pg_version }}
    - require:
      - pkgrepo: postgresql
  service.running:
    - name: postgresql
    - enable: True
    - require:
      - pkg: postgresql

# Upload access configuration for postgres.
/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - source: salt://postgres/files/pg_hba.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 640
    - watch_in:
      - service: postgresql

# Upload custom configuration if defined.
{% if pillar.postgres.configuration %}
/etc/postgresql/{{ pg_version }}/main/conf.d/030_{{ pillar.postgres.configuration }}.conf:
  file.managed:
    - source: salt://postgres/files/{{ pillar.postgres.configuration }}.conf
    - template: jinja
    - user: postgres
    - group: postgres
    - mode: 640
    - watch_in:
      - service: postgresql
{% endif %}

# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
# https://github.com/jfcoz/postgresqltuner
vm.overcommit_memory:
  sysctl.present:
    - value: 2

# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES
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
