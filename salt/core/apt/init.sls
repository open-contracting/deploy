# Disable operating system release notifications.
/etc/update-manager/release-upgrades:
  file.keyvalue:
    - key: Prompt
    - value: never

/etc/apt/apt.conf.d/99-connection-timeouts:
  file.managed:
    - source: salt://core/apt/files/99-connection-timeouts

needrestart:
  pkg.removed:
    - name: needrestart
