memcached:
  pkg.installed:
    - name: memcached
  service.running:
    - name: memcached
    - enable: True
    - require:
      - pkg: memcached

{% if salt['pillar.get']('memcached:public_access') %}
/etc/memcached.conf:
  file.replace:
    - pattern: -l 127.0.0.1
    - repl: -l 0.0.0.0
    - backup: False
    - require:
      - pkg: memcached
    - watch_in:
      - service: memcached
{% endif %}
