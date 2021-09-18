rabbitmq:
  pkg.installed:
    - name: rabbitmq-server
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq

rabbitmq_management:
  rabbitmq_plugin.enabled:
    - name: rabbitmq_management

{% if not pillar.rabbitmq.get('guest_enabled') %}
# https://www.rabbitmq.com/access-control.html#default-state
delete guest rabbitmq user:
  rabbitmq_user.absent:
    - name: guest
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
      - service: rabbitmq
{% endfor %}
{% endif %}
