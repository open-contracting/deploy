## Swap
{% set swap_path = "/swapfile" %}
{% set swappiness_value = 10 %}

# Calculate swap size based on RAM
#If RAM is more than 32 GB, swap size should be a quarter of the RAM
{% if grains["mem_total"] > 32768 %}
{% set swap_size = grains["mem_total"]/4 %}

#If RAM is more than 2 GB, swap size should be half of the RAM
{% elif grains["mem_total"] > 2048 %}
{% set swap_size = grains["mem_total"]/2 %}

#If RAM is less than 2 GB, swap size should be equal to the RAM
{% else %}
{% set swap_size = grains["mem_total"] %}

# Also increase use of swap on a smaller instance.
{% set swappiness_value = 40 %}
{% endif %}


## Create swap file and mount
{{ swap_path }}:
  cmd.run:
    - name: |
        fallocate -l {{ swap_size }}M {{ swap_path }}
        chmod 0600 {{ swap_path }}
        mkswap {{ swap_path }}
    - creates: {{ swap_path }}
  mount.swap:
    - persist: true

## Set swappiness so that it is only used when memory is full
vm.swappiness:
  sysctl.present:
    - config: /etc/sysctl.d/99-swappiness.conf
    - value: {{ swappiness_value }}
    
