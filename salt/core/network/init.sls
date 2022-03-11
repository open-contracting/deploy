# Don't apply to servers that pre-exist the `network` approach.
{%- if 'network' in pillar %}

# `order` is used, to ensure these states run before others.

{{ pillar.network.ipv4 }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.network.host_id }}.open-contracting.org
      - {{ pillar.network.host_id }}

{%- if 'ipv6' in pillar.network %}
{{ pillar.network.ipv6 }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.network.host_id }}.open-contracting.org
      - {{ pillar.network.host_id }}
{% endif %}

/etc/mailname:
  file.managed:
    - order: 5
    - contents: "{{ pillar.network.host_id }}.open-contracting.org"

# The Salt system.networking state does not fully support Ubuntu 20.04 yet so we are using cmd.run instead.
set hostname:
  cmd.run:
    - order: 10
    - name: hostnamectl set-hostname "{{ pillar.network.host_id }}.open-contracting.org"
    - onchanges:
      - file: /etc/mailname

{%- if 'netplan' in pillar.network %}
/etc/netplan/01-netcfg.yaml:
  file.absent

# Linode-only. https://www.linode.com/docs/guides/linux-static-ip-configuration/#disable-network-helper
/etc/systemd/network/05-eth0.network:
  file.absent

/etc/netplan/10-salt-networking.yaml:
  file.managed:
    - source: salt://core/network/files/netplan_{{ pillar.network.netplan.configuration }}.yaml
    - template: jinja

netplan_apply:
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
        - file: /etc/netplan/10-salt-networking.yaml
{% endif %}

{% endif %}
