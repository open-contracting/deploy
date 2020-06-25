# Disable Ubuntu release notifications.
/etc/update-manager/release-upgrades:
  file.replace:
    - name:
    - pattern: "Prompt=lts"
    - repl: "Prompt=never"
