# Disable operating system release notifications.
/etc/update-manager/release-upgrades:
  file.replace:
    - pattern: "Prompt=lts"
    - repl: "Prompt=never"

/etc/apt/apt.conf.d/99-connection-timeouts:
  file.managed:
    - source: salt://core/apt/files/99-connection-timeouts
