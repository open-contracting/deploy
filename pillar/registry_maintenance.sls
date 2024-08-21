maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOWHIDDENFILE=/etc/.resolv.conf.systemd-resolved.bak
    ALLOWHIDDENFILE=/etc/.updated
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
    PORT_WHITELIST=TCP:60922
    DISABLE_TESTS=running_procs
  hardware_sensors: True
  custom_sensors:
     - coretemp
     - nct6775
