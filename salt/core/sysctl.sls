{% set exclude_list = ['overcommit_memory'] %}
{% for name, value in salt['pillar.get']('vm', {}) | items | rejectattr("0", "in", exclude_list) %}
vm.{{name}}:
  sysctl.present:
    - value: {{ value }}
{% endfor %}

# https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-MEMORY-OVERCOMMIT
# https://github.com/open-contracting/deploy/issues/524
{% if salt['pillar.get']('vm:overcommit_memory') %}
{% set vm_overcommit_memory = pillar.vm.overcommit_memory %}
{% elif salt['pillar.get']('redis') %}
{% set vm_overcommit_memory = 1 %}
{% elif salt['pillar.get']('postgres') %}
{% set vm_overcommit_memory = 2 %}
{% endif %}

{% if vm_overcommit_memory %}
vm.overcommit_memory:
  sysctl.present:
    - value: {{ vm_overcommit_memory }}
{% endif %}
