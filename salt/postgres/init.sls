# Install postgres from the official repositories as they offer newer versions than os repos.
{% from 'lib.sls' import configurefirewall %}

# Default to postgres version 11, if not defined in pillar.
{% set pg_version = salt['pillar.get']('postgres:version', '11') %}

{{ configurefirewall("PUBLICPOSTGRESSERVER") }}

# Install and start postgres.
postgresql:
  pkgrepo.managed:
    - humanname: PostgreSQL Official Repository
    - name: deb https://apt.postgresql.org/pub/repos/apt/ {{ grains['oscodename'] }}-pgdg main
    - dist: {{ grains['oscodename'] }}-pgdg
    - file: /etc/apt/sources.list.d/psql.list
    - key_url: https://www.postgresql.org/media/keys/ACCC4CF8.asc
  pkg.installed:
    - name: postgresql-{{ pg_version }}
  service.running:
    - enable: True

# Upload access configuration for postgres.
/etc/postgresql/{{ pg_version }}/main/pg_hba.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source:
      - salt://postgres/configs/pg_hba.conf
    - template: jinja
    - watch_in:
      - service: postgresql

# Upload custom configuration if defined.
{% if pillar.postgres.configuration_file %}
/etc/postgresql/{{ pg_version }}/main/conf.d/030_{{ pillar.postgres.configuration_name }}.conf:
  file.managed:
    - user: postgres
    - group: postgres
    - mode: 640
    - source:
      - {{ pillar.postgres.configuration_file }}
    - watch_in:
      - service: postgresql
{% endif %}

# https://github.com/jfcoz/postgresqltuner (BAD)
# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
vm.overcommit_memory:
  sysctl.present:
    - value: 2

# https://github.com/jfcoz/postgresqltuner (WARN)
# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES
{% if pillar.vm.nr_hugepages %}
vm.nr_hugepages:
  sysctl.present:
    - value: {{ pillar.vm.nr_hugepages }}
{% endif %}
