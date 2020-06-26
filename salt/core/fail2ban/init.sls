include:
  - core.mail

fail2ban:
  pkg.installed

f2b-startup:
  service.running:
    - name: fail2ban
    - enable: True
    - reload: True
  require:
    - pkg: fail2ban
    - sls: core.mail
  watch:
    - file: /etc/fail2ban/jail.local

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://core/fail2ban/jail.local

