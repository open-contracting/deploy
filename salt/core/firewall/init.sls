# This state file initialises the required files for the firewall script.

iptables-persistent:
  pkg.installed

# To avoid updating iptables on each deploy, this sets `replace: False`. If the source file is changed, you must delete
# the remote file from all servers, then re-deploy. (Or, temporarily set `replace: True`.)
/home/sysadmin-tools/firewall-settings.local:
  file.managed:
    - source: salt://core/firewall/files/firewall-settings.local
    - template: jinja
    - mode: 640
    - replace: False

/home/sysadmin-tools/bin/firewall.sh:
  file.managed:
    - source: salt://core/firewall/files/firewall.sh
    - mode: 750
  require:
    - file: /home/sysadmin-tools/bin

# We upload the script and execute it on the server (rather than using cmd.script). This has the following benefits:
# - Users on the system can regenerate the firewall without re-deploying (for example, to block an IP temporarily)
# - We can ensure the order of iptables rules, so important traffic is addressed first.
# - We remove any undocumented rules.
save iptables rules:
  cmd.run:
  - name: "/home/sysadmin-tools/bin/firewall.sh"
  - onchanges:
    - file: /home/sysadmin-tools/firewall-settings.local
    - file: /home/sysadmin-tools/bin/firewall.sh
