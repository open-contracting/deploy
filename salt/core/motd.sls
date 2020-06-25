disable default ubuntu motds:
  file.managed:
  - mode: 644
  - names:
    - /etc/update-motd.d/10-help-text
    - /etc/update-motd.d/80-livepatch

/etc/default/motd-news:
  file.replace:
  - pattern: "^ENABLED=.*"
  - repl: ENABLED=0
