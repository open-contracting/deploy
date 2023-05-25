maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    ALLOW_SSH_ROOT_USER=yes
    RTKT_FILE_WHITELIST=/usr/lib/x86_64-linux-gnu/libkeyutils.so.1.9
    USER_FILEPROP_FILES_DIRS=/usr/lib/x86_64-linux-gnu/libkeyutils.so.1.9
