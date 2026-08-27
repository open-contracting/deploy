redis:
  pkg.installed:
    - name: redis-server
  service.running:
    - name: redis-server
    - enable: True
    - require:
      - pkg: redis

{% if pillar.redis.configuration is defined %}
/etc/redis/local.conf:
  file.managed:
    - source: salt://redis/files/conf/{{ pillar.redis.configuration }}.conf
    - template: jinja
    - context: {{ pillar.redis.get('context', {})|yaml }}
    - user: redis
    - group: redis
    - mode: 640
    - require:
      - pkg: redis
    - watch_in:
      - service: redis

include local.conf in redis.conf:
  file.append:
    - name: /etc/redis/redis.conf
    - text: include /etc/redis/local.conf
    - require:
      - file: /etc/redis/local.conf
    - watch_in:
      - service: redis
{% endif %}
