# Configure an SNTP service.
systemd-timesyncd:
  pkg.installed:
    - name: systemd-timesyncd
  service.running:
    - name: systemd-timesyncd
    - enable: True
    - require:
      - pkg: systemd-timesyncd

/etc/systemd/timesyncd.conf.d/customization.conf:
  file.managed:
    - source: salt://core/systemd/files/timesyncd.conf
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: systemd-timesyncd

/etc/systemd/timesyncd.conf:
  file.comment:
    - regex: "^NTP="
    - backup: False
    - watch_in:
      - service: systemd-timesyncd

set timezone to utc:
  timezone.system:
    - name: UTC
