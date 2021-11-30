maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    SCRIPTWHITELIST=/usr/bin/egrep
    SCRIPTWHITELIST=/usr/bin/fgrep
    SCRIPTWHITELIST=/usr/bin/which
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
    PORT_WHITELIST=TCP:60922
    DISABLE_TESTS=running_procs
  hardware_sensors: True
  custom_sensors:
    - nct6775
    - k10temp
