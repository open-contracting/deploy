# This state file initialises the required files for the firewall script.
# 

{% from 'lib.sls' import configurefirewall %}

iptables-persistent:
  pkg.installed

/home/sysadmin-tools/bin:
  file.directory:
    - makedirs: True

/home/sysadmin-tools/firewall-settings.local:
  file.managed:
    - replace: False
    - mode: 640



{{ configurefirewall("ADDADMINIPS", ' '.join(pillar['admin_ips']['ipv4']) ) }}
{{ configurefirewall("ADDADMIN6IPS", ' '.join(pillar['admin_ips']['ipv6']) ) }}

# We are uploading the script and executing server side (rather than running one off using cmd.script).
# This has the following benefits:
# - Users on the system can regenerate the firewall without redeploying (blocking an IP temporarily for example)
# - We can ensure the order of IPTables rules so important traffic is addressed first.
# - We remove any non-documented rules 
Upload firewall script:
  file.managed:
    - name: /home/sysadmin-tools/bin/firewall.sh
    - source: salt://lib/firewall.sh
    - mode: 750

/home/sysadmin-tools/bin/firewall.sh:
  cmd.run:
  - name: "/home/sysadmin-tools/bin/firewall.sh"
  - onchanges:
    - file: /home/sysadmin-tools/firewall-settings.local
    - file: Upload firewall script
