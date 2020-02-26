tinyproxy:
  pkg.installed:
    - name: tinyproxy
  service.running:
    - name: tinyproxy
    - enable: True
    - restart: True

/etc/tinyproxy/tinyproxy.conf:
  file.managed:
    - source: salt://tinyproxy/tinyproxy.conf
    - template: jinja
    - makedirs: True
    - context:
        ipallows: {{ pillar.tinyproxy.ipallows|yaml }}
    - watch_in:
      - service: tinyproxy
