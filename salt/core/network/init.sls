# Don't apply to servers that pre-exist the `network` approach.
{% if 'network' in pillar %}

# `order` is used, to ensure these states run before others.

{{ pillar.network.ipv4 }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.network.host_id }}.{{ pillar.network.domain }}
      - {{ pillar.network.host_id }}

{% if 'ipv6' in pillar.network %}
{{ pillar.network.ipv6 }}:
  host.only:
    - order: 5
    - hostnames:
      - {{ pillar.network.host_id }}.{{ pillar.network.domain }}
      - {{ pillar.network.host_id }}
{% endif %}

/etc/mailname:
  file.managed:
    - order: 5
    - contents: "{{ pillar.network.host_id }}.{{ pillar.network.domain }}"

# Salt's `network` module uses Debian's `/etc/network/interfaces` file, not Netplan (from reading its code).
# https://github.com/open-contracting/deploy/issues/278#issuecomment-924485063
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.network.html
set hostname:
  cmd.run:
    - order: 10
    - name: hostnamectl set-hostname "{{ pillar.network.host_id }}.{{ pillar.network.domain }}"
    - onchanges:
      - file: /etc/mailname

{% if 'networkd' in pillar.network %}
/etc/netplan/01-netcfg.yaml:
  file.absent

/etc/netplan/01-eth0.yaml:
  file.absent

/etc/systemd/network/05-eth0.network:
  file.managed:
    - source: salt://core/network/files/networkd_{{ pillar.network.networkd.template }}.network
    - template: jinja

systemd-networkd:
  service.running:
    - name: systemd-networkd
    - enable: True
{% elif 'netplan' in pillar.network %}
/etc/netplan/01-netcfg.yaml:
  file.absent

# Linode-only. https://www.linode.com/docs/products/compute/compute-instances/guides/network-helper/#enable-or-disable-network-helper
/etc/systemd/network/05-eth0.network:
  file.absent

/etc/netplan/10-salt-networking.yaml:
  file.managed:
    - mode: 600
    - source: salt://core/network/files/netplan_{{ pillar.network.netplan.template }}.yaml
    - template: jinja

netplan_apply:
  cmd.run:
    - name: netplan generate && netplan apply
    - onchanges:
      - file: /etc/netplan/10-salt-networking.yaml
{% endif %}

{% endif %}
