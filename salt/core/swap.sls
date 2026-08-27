# Set desired swap size
{% if grains.mem_total > 32768 %}
  {% set swap_size = [grains.mem_total // 4, 16384] | max %}
{% elif grains.mem_total > 8192 %}
  {% set swap_size = grains.mem_total // 2 %}
{% else %}
  {% set swap_size = 4096 %}
{% endif %}

{% if salt['pillar.get']('vm:swappiness') %}
  {% set vm_swappiness = pillar.vm.swappiness %}
{% elif grains.mem_total > 4096 %}
  {% set vm_swappiness = 10 %}
{% else %}
  {% set vm_swappiness = 40 %}
{% endif %}

{% set swap_path = '/swapfile' %}

# Some systems will have swap configured already, if it is sufficient then don't configure more.
{% set swap_diff = swap_size - grains.swap_total %}
{% if swap_diff >= 512 %}
# Create swap file and mount. Only runs if `swap_path` has not been created.
{{ swap_path }}:
  cmd.run:
    - name: |
        fallocate -l {{ swap_diff }}M {{ swap_path }}
        chmod 0600 {{ swap_path }}
        mkswap {{ swap_path }}
    - creates: {{ swap_path }}
  mount.swap:
    - persist: True
{% endif %}
