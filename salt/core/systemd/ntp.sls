# Configure an SNTP service.
systemd-timesyncd:
  {% if grains['osrelease'] >= '20.04' %}
  # timesyncd is built into systemd on older Ubuntu releases.
  pkg.installed:
    - name: systemd-timesyncd
  {% endif %}
  service.running:
    - name: systemd-timesyncd
    - enable: True
    {% if grains['osrelease'] >= '20.04' %}
    - require:
      - pkg: systemd-timesyncd
    {% endif %}

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
