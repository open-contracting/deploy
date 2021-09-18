# Configure an NTP service
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
    - makedirs: True
    - watch_in:
      - service: systemd-timesyncd

/etc/systemd/timesyncd.conf:
  file.comment:
    - regex: "^NTP="
    - backup: False
    - watch_in:
      - service: systemd-timesyncd

# Catch instances where ntp has been installed protecting against two NTP services running at once.
ntp:
  service.dead:
    - enable: False

set timezone to utc:
  timezone.system:
    - name: UTC
