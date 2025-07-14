maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOW_SSH_ROOT_USER=yes
    ALLOWHIDDENFILE=/etc/.resolv.conf.systemd-resolved.bak
    ALLOWHIDDENFILE=/etc/.updated
