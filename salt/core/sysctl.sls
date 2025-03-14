{% for name, value in salt['pillar.get']('vm', {})|items %}
{% if name != 'overcommit_memory' %}
vm.{{ name }}:
  sysctl.present:
    - value: {{ value }}
{% endif %}
{% endfor %}

# https://github.com/open-contracting/deploy/issues/524
{% if salt['pillar.get']('vm:overcommit_memory') %}
{% set vm_overcommit_memory = pillar.vm.overcommit_memory %}
{% elif salt['pillar.get']('redis') %}
# https://redis.io/docs/latest/operate/oss_and_stack/management/admin/
{% set vm_overcommit_memory = 1 %}
{% elif salt['pillar.get']('postgres') %}
# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
{% set vm_overcommit_memory = 2 %}
{% endif %}

{% if vm_overcommit_memory %}
vm.overcommit_memory:
  sysctl.present:
    - value: {{ vm_overcommit_memory }}
{% endif %}
