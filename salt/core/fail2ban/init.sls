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
      - sls: core.mail

/etc/fail2ban/filter.d/apache-custom-404.conf:
  file.managed:
    - contents: |
        [Definition]
        failregex = ^<HOST> .* 404
        ignoreregex =

/etc/fail2ban/jail.local:
  file.managed:
    - source: salt://core/fail2ban/files/jail.local
    - template: jinja
    - watch_in:
      - service: fail2ban
