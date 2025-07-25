# https://github.com/salt-formulas/salt-formula-rabbitmq/blob/master/rabbitmq/server/service.sls

rabbitmq-erlang:
  pkgrepo.managed:
    - humanname: Erlang Official Repository
    - name: deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq-erlang.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/{{ grains.oscodename }} {{ grains.oscodename }} main
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/rabbitmq_erlang.list
    - key_url: https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA
    - aptkey: False

rabbitmq-server:
  pkgrepo.managed:
    - humanname: RabbitMQ Official Repository
    - name: deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq-server.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/{{ grains.oscodename }} {{ grains.oscodename }} main
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/rabbitmq_server.list
    - key_url: https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA
    - aptkey: False
    - require:
      - pkgrepo: rabbitmq-erlang
  pkg.installed:
    - name: rabbitmq-server
    - require:
      - pkgrepo: rabbitmq-server
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq-server

/etc/rabbitmq/rabbitmq.conf:
  file.managed:
    - source: salt://rabbitmq/files/rabbitmq.conf
    - user: rabbitmq
    - group: rabbitmq
    - makedirs: True
    - mode: 440
    - require:
      - pkg: rabbitmq-server
    - watch_in:
      - service: rabbitmq-server

# If needed, can increase the maximum open file descriptors via /etc/systemd/system/rabbitmq-server.service.d/limits.conf
# https://www.rabbitmq.com/docs/configure#kernel-limits

# Can substitute Prometheus for long-term metric storage and a decoupled monitoring system.
# https://www.rabbitmq.com/docs/monitoring
# https://www.rabbitmq.com/docs/prometheus
rabbitmq_management:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_management
    - require:
      - service: rabbitmq-server

{% if not salt['pillar.get']('rabbitmq:guest_enabled') %}
# https://www.rabbitmq.com/docs/access-control#default-state
delete guest rabbitmq user:
  rabbitmq_user.absent:
    - name: guest
    - require:
      - service: rabbitmq-server
{% endif %}

{% for name, entry in salt['pillar.get']('rabbitmq:users', {})|items %}
create {{ name }} rabbitmq user:
  rabbitmq_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
{% if 'tags' in entry %}
    # https://www.rabbitmq.com/docs/management#permissions
    - tags: {{ entry.tags|yaml }}
{% endif %}
    # https://www.rabbitmq.com/docs/access-control#authorisation
    - perms:
      - '/':
        - {% if entry.get('write') %}'.*'{% else %}'^$'{% endif %} # configure
        - {% if entry.get('write') %}'.*'{% else %}'^$'{% endif %} # write
        - '.*' # read
    - require:
      - service: rabbitmq-server
{% endfor %}
