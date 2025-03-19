{% for name, value in salt['pillar.get']('vm', {})|items %}
{% if name not in ('overcommit_memory', 'overcommit_ratio') %}
vm.{{ name }}:
  sysctl.present:
    - value: {{ value }}
{% endif %}
{% endfor %}

{% if salt['pillar.get']('vm:overcommit_memory') %}
{% set vm_overcommit_memory = pillar.vm.overcommit_memory %}
{% elif salt['pillar.get']('redis') %}
# https://redis.io/docs/latest/operate/oss_and_stack/management/admin/
{% set vm_overcommit_memory = 1 %}
{% elif salt['pillar.get']('postgres') %}
# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
{% set vm_overcommit_memory = 2 %}
{% endif %}

{% if vm_overcommit_memory is defined %}
vm.overcommit_memory:
  sysctl.present:
    - value: {{ vm_overcommit_memory }}
{% endif %}

{% if salt['pillar.get']('vm:overcommit_ratio') %}
{% set vm_overcommit_ratio = pillar.vm.overcommit_ratio %}
{% elif vm_overcommit_memory is defined and vm_overcommit_memory == 2 %}
{% set vm_overcommit_ratio = 90 %}
{% endif %}

{% if vm_overcommit_ratio is defined %}
vm.overcommit_ratio:
  sysctl.present:
    - value: {{ vm_overcommit_ratio }}
{% endif %}
