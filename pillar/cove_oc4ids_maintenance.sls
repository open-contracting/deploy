maintenance:
  enabled: True
  patching: manual
  rkhunter_customisation: |
    SCRIPTWHITELIST=/usr/bin/egrep
    SCRIPTWHITELIST=/usr/bin/fgrep
    SCRIPTWHITELIST=/usr/bin/which.debianutils
    RTKT_FILE_WHITELIST=/usr/lib/x86_64-linux-gnu/libkeyutils.so.1.9
    USER_FILEPROP_FILES_DIRS=/usr/lib/x86_64-linux-gnu/libkeyutils.so.1.9