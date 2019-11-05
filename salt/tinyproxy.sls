tinyproxy-deps:
  pkg.installed:
    - name: tinyproxy

/etc/tinyproxy/tinyproxy.conf:
  file.managed:
    - source: salt://tinyproxy/tinyproxy.conf
    - template: jinja
    - makedirs: True
    - context:
        ipallow: "{{ pillar.tinyproxy.ipallow }}"
