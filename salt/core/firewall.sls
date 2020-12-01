# This state file initialises the required files for the firewall script.

iptables-persistent:
  pkg.installed

/home/sysadmin-tools/bin:
  file.directory:
    - makedirs: True

/home/sysadmin-tools/firewall-settings.local:
  file.managed:
    - source: salt://lib/firewall-settings.local
    - mode: 640
    - template: jinja

/home/sysadmin-tools/bin/firewall.sh:
  file.managed:
    - source: salt://lib/firewall.sh
    - mode: 750

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
