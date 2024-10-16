/etc/systemd/journald.conf.d/customization.conf:
  file.managed:
    - contents: |
        [Journal]
        SystemMaxUse=1024M
    - user: root
    - group: root
    - makedirs: True
    - watch_in:
      - service: systemd-journald

systemd-journald:
  service.running:
    - name: systemd-journald
