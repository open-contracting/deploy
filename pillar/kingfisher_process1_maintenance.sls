maintenance:
  enabled: true
  patching: manual
  rkhunter_customisation: |
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
  hardware_sensors: true
  custom_sensors:
    - coretemp
