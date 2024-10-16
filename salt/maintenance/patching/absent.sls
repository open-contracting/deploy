# Provides 'usr/lib/update-notifier/apt-check' used by check_update.sh
update-notifier-common:
  pkg.installed:
    - name: update-notifier-common

/etc/cron.daily/check_update:
  file.managed:
    - source: salt://maintenance/patching/files/check_update.sh
    - mode: 755

unattended-upgrades:
  pkg.removed:
    - name: unattended-upgrades
  debconf.set:
    - data:
        'unattended-upgrades/enable_auto_updates': {'type': 'boolean', 'value': false }
  file.absent:
    - name: /etc/apt/apt.conf.d/99autopatch
