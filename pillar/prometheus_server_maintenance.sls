maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOW_SSH_ROOT_USER=yes
    ALLOWDEVFILE=/dev/shm/sem.haveged_sem
