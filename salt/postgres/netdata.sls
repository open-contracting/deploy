# Move to another state, if netdata is re-implemented.
netdata:
  service.running:
    - name: netdata

{% if not pillar.postgres.get('replication') %}
# https://learn.netdata.cloud/docs/collecting-metrics/databases/postgresql#setup
netdata_sql_user:
  postgres_user.present:
    - name: netdata
    - password: "{{ pillar.netdata.postgres }}"
    - groups:
      - pg_monitor
    - require:
      - service: postgresql

/etc/netdata/go.d/postgres.conf:
  file.managed:
    - source: salt://postgres/files/netdata.conf
    - template: jinja
    - makedirs: True
    - mode: 600
    - require:
      - postgres_user: netdata_sql_user
    - watch_in:
      - service: netdata
{% endif %}
