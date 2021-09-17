rabbitmq:
  pkg.installed:
    - name: rabbitmq-server
  service.running:
    - name: rabbitmq-server
    - enable: True
    - require:
      - pkg: rabbitmq

{% if salt['pillar.get']('rabbitmq:users') %}
{% for name, entry in pillar.rabbitmq.users.items() %}
rabbitmq-user-{{ name }}:
  rabbitmq_user.present:
    - name: {{ name }}
{% if 'password' in entry %}
    - password: "{{ entry.password }}"
{% endif %}
    - require:
      - service: rabbitmq
{% endfor %}
{% endif %}
