# "Executable scripts in /etc/update-motd.d/* are executed by pam_motd(8) as the root user at each login."
# https://manpages.ubuntu.com/manpages/hirsute/en/man5/update-motd.5.html
disable default motds:
  file.managed:
    - names:
      - /etc/update-motd.d/10-help-text
    - mode: 644

/etc/default/motd-news:
  file.keyvalue:
    - key: ENABLED
    - value: 0
    - ignore_if_missing: True
