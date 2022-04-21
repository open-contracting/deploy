maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
    SCRIPTWHITELIST=/usr/bin/egrep
    SCRIPTWHITELIST=/usr/bin/fgrep
    SCRIPTWHITELIST=/usr/bin/which
