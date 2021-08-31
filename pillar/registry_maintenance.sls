maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    SCRIPTWHITELIST=/usr/bin/egrep
    SCRIPTWHITELIST=/usr/bin/fgrep
    SCRIPTWHITELIST=/usr/bin/which
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
<<<<<<< HEAD
    PORT_PATH_WHITELIST=/usr/local/bin/python3.9:TCP:60922
=======
    PORT_PATH_WHITELIST="/usr/bin/docker-proxy:TCP:60922"
>>>>>>> 7808b84f748c486e0c4ae3b2705f928f25af9931
  hardware_sensors: True
  custom_sensors:
    - nct6775
    - k10temp
