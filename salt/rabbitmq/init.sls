# https://github.com/salt-formulas/salt-formula-rabbitmq/blob/master/rabbitmq/server/service.sls

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server
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
# https://www.rabbitmq.com/configure.html#kernel-limits

# Can substitute Prometheus for long-term metric storage and a decoupled monitoring system.
# https://www.rabbitmq.com/monitoring.html
# https://www.rabbitmq.com/prometheus.html
rabbitmq_management:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_management
    - require:
      - service: rabbitmq-server

{% if not salt['pillar.get']('rabbitmq:guest_enabled') %}
# https://www.rabbitmq.com/access-control.html#default-state
delete guest rabbitmq user:
  rabbitmq_user.absent:
    - name: guest
    - require:
      - service: rabbitmq-server
{% endif %}

{% if salt['pillar.get']('rabbitmq:users') %}
{% for name, entry in pillar.rabbitmq.users.items() %}
create {{ name }} rabbitmq user:
  rabbitmq_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
    # https://www.rabbitmq.com/management.html#permissions
    - tags:
      - management
    # https://www.rabbitmq.com/access-control.html#authorisation
    - perms:
      - '/':
        - '.*'
        - '.*'
        - '.*'
    - require:
      - service: rabbitmq-server
{% endfor %}
{% endif %}
