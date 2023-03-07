# https://github.com/salt-formulas/salt-formula-rabbitmq/blob/master/rabbitmq/server/service.sls

rabbitmq-dependancies:
  pkg.installed:
    - pkgs:
      - gnupg2
      - apt-transport-https

erlang repo:
  pkgrepo.managed:
    - humanname: Erlang Official Repository
    - name: deb http://ppa.launchpad.net/rabbitmq/rabbitmq-erlang/ubuntu {{ grains.oscodename }} main
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/rabbitmq_erlang.list
    - key_url: https://keyserver.ubuntu.com/pks/lookup?op=get&search=0xf77f1eda57ebb1cc

rabbitmq-server:
  pkgrepo.managed:
    - humanname: RabbitMQ Official Repository
    - name: deb https://packagecloud.io/rabbitmq/rabbitmq-server/ubuntu/ {{ grains.oscodename }} main
    - dist: {{ grains.oscodename }}
    - file: /etc/apt/sources.list.d/rabbitmq_server.list
    - key_url: https://packagecloud.io/rabbitmq/rabbitmq-server/gpgkey
  pkg.installed:
    - name: rabbitmq-server
    - require:
      - pkg: rabbitmq-dependancies
      - pkgrepo: "erlang repo"
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
{% if 'tags' in entry %}
    # https://www.rabbitmq.com/management.html#permissions
    - tags: {{ entry.tags|yaml }}
{% endif %}
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
