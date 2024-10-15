/etc/cron.daily/check_update:
  file.absent

# Configure unattended-upgrades.
unattended-upgrades:
  pkg.installed:
    - name: unattended-upgrades
  debconf.set:
    - data:
        'unattended-upgrades/enable_auto_updates': {'type': 'boolean', 'value': true }
  file.managed:
    - name: /etc/apt/apt.conf.d/99autopatch
    - source: salt://maintenance/patching/files/99autopatch
  cmd.run:
    - name: dpkg-reconfigure -f noninteractive unattended-upgrades
    - require:
      - pkg: unattended-upgrades
    - onchanges:
      - debconf: unattended-upgrades
