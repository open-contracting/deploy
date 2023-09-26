maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOWDEVFILE=/dev/shm/PostgreSQL.*
    DISABLE_TESTS=running_procs
