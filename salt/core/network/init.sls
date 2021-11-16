# Define order so that these configuration options are ran before everything else.
# Other packages and commands rely on the hostname field being configured.

# Don't run on old/existing servers prior to network configuration.
{%- if 'network' in pillar %}
{{ pillar.network.ipv4.primary_ip }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.host_id }}.open-contracting.org
      - {{ pillar.host_id }}
{%- if 'ipv6' in pillar.network %}
{{ pillar.network.ipv6.primary_ip }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.host_id }}.open-contracting.org
      - {{ pillar.host_id }}
{% endif %}

/etc/mailname:
  file.managed:
    - order: 5
    - contents: "{{ pillar.host_id }}.open-contracting.org"

# The salt system.networking state does not fully support Ubuntu 20.04 yet.
set hostname:
  cmd.run:
    - order: 10
    - name: hostnamectl set-hostname "{{ pillar.host_id }}.open-contracting.org"
    - onchanges:
        - file: /etc/mailname

{%- if 'netplan' in pillar.network %}
# We manually configure networking on Linode servers so that we can use our own IPv6 /64 range.
# https://www.linode.com/docs/guides/linux-static-ip-configuration/#disable-network-helper
/etc/systemd/network/05-eth0.network:
  file.absent

/etc/netplan/01-netcfg.yaml:
  file.absent

{%- if 'custom_netplan' in pillar.network %}
/etc/netplan/10-salt-networking.yaml:
  file.serialize:
    - dataset_pillar: network:custom_netplan
    - formatter: yaml
{% else %}
/etc/netplan/10-salt-networking.yaml:
  file.managed:
    - source: salt://core/network/files/netplan_template.yml
    - template: jinja
{% endif %}

netplan_apply:
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
        - file: /etc/netplan/10-salt-networking.yaml
{% endif %}
{% endif %}
