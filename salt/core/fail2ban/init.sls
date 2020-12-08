include:
  - core.mail

fail2ban:
  pkg.installed:
    - name: fail2ban
  service.running:
    - name: fail2ban
    - enable: True
    - reload: True
    - require:
      - pkg: fail2ban
  require:
    - sls: core.mail
  watch:
    - file: /etc/fail2ban/jail.local

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://core/fail2ban/files/jail.local
