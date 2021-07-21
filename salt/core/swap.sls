{% if grains.mem_total > 32768 %}
  {% set swap_size = [grains.mem_total // 4, 16384] | max %}
{% elif grains.mem_total > 2048 %}
  {% set swap_size = grains.mem_total // 2 %}
{% else %}
  {% set swap_size = grains.mem_total %}
{% endif %}

{% if salt['pillar.get']('vm:swappiness') %}
  {% set vm_swappiness = pillar.vm.swappiness %}
{% elif grains.mem_total > 2048 %}
  {% set vm_swappiness = 10 %}
{% else %}
  {% set vm_swappiness = 40 %}
{% endif %}

{% set swap_path = "/swapfile" %}

# Some systems will have swap configured already, if it is sufficent then don't configure more.
{% if swap_size > grains['swap_total'] %}
# Create swap file and mount.
# Only runs if swap_path has not been created
{{ swap_path }}:
  cmd.run:
    - name: |
        fallocate -l {{ swap_size }}M {{ swap_path }}
        chmod 0600 {{ swap_path }}
        mkswap {{ swap_path }}
    - creates: {{ swap_path }}
  mount.swap:
    - persist: True
{% endif %}

# Set swappiness so that it is only used when memory is full.
vm.swappiness:
  sysctl.present:
    - config: /etc/sysctl.d/99-swappiness.conf
    - value: {{ vm_swappiness }}
