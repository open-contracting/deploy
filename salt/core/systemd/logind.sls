# Stop RemoveIPC killing all processes by a user when they log out.
/etc/systemd/logind.conf.d/customization.conf:
  file.managed:
    - source: salt://core/systemd/files/logind.conf
    - makedirs: True
    - watch_in:
      - service: systemd-logind

systemd-logind:
  service.running:
    - name: systemd-logind
