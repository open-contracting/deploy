# Disable Ubuntu release notifications.
/etc/update-manager/release-upgrades:
  file.replace:
    - pattern: "Prompt=lts"
    - repl: "Prompt=never"
