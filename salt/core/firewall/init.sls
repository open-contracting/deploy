{% from 'lib.sls' import set_firewall %}

iptables-persistent:
  pkg.installed:
    - name: iptables-persistent

# To avoid updating iptables on each deploy, this sets `replace: False`. If the source file is changed, you must delete
# the remote file from all servers, then re-deploy. (Or, temporarily set `replace: True`.)
/home/sysadmin-tools/firewall-settings.local:
  file.managed:
    - source: salt://core/firewall/files/firewall-settings.local
    - mode: 640
    - replace: False
    - require:
      - file: /home/sysadmin-tools/bin

{% set ssh_ipv4_ips = salt['pillar.get']('firewall:ssh_ipv4', []) + salt['pillar.get']('firewall:additional_ssh_ipv4', []) %}
{% set ssh_ipv6_ips = salt['pillar.get']('firewall:ssh_ipv6', []) + salt['pillar.get']('firewall:additional_ssh_ipv6', []) %}

{{ set_firewall("SSH_IPV4", ssh_ipv4_ips|join(' ')) }}
{{ set_firewall("SSH_IPV6", ssh_ipv6_ips|join(' ')) }}

/home/sysadmin-tools/bin/firewall.sh:
  file.managed:
    - source: salt://core/firewall/files/firewall.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin

# We upload the script and execute it on the server (rather than using cmd.script). This has the following benefits:
# - Users on the system can regenerate the firewall without re-deploying (for example, to block an IP temporarily)
# - We can ensure the order of iptables rules, so important traffic is addressed first.
# - We remove any undocumented rules.
save iptables rules:
  cmd.run:
    - name: /home/sysadmin-tools/bin/firewall.sh
    - onchanges:
      - file: /home/sysadmin-tools/firewall-settings.local
      - file: /home/sysadmin-tools/bin/firewall.sh

/home/sysadmin-tools/bin/firewall_reset.sh:
  file.managed:
    - source: salt://core/firewall/files/firewall_reset.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin
