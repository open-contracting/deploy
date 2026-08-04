# Configure an SNTP service.
{% if grains.osmajorrelease|int >= 26 %}
chrony:
  service.running:
    - name: chrony

chrony-reload:
  cmd.wait:
    - name: chronyc reload sources

/etc/chrony/sources.d/ntp-pools.sources:
  file.managed:
    - source: salt://core/ntp/files/ntp-pools.sources
    - template: jinja
    - watch_in:
      - cmd: chrony-reload

/etc/chrony/sources.d/ubuntu-ntp-pools.sources:
  file.comment:
    - regex: "^pool "
    - backup: False
    - watch_in:
      - cmd: chrony-reload

{% else %}
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
    - source: salt://core/ntp/files/timesyncd.conf
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
{% endif %}

set timezone to utc:
  timezone.system:
    - name: UTC
