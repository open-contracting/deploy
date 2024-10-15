# Install and configure hardware sensors checks.
#
# Run `sensors-detect` on the server to configure maintenance:custom_sensors.

lm-sensors:
  pkg.installed:
     - name: lm-sensors

{% for module in salt['pillar.get']('maintenance:custom_sensors', []) %}
{{ module }}:
  kmod.present:
    - persist: True

# This is not a typo: the nct6779 and nct6798 sensor requires the nct6775 module.
{% if module == 'nct6775' %}
/etc/sensors.d/nct6779.conf:
  file.managed:
    - source: salt://maintenance/hardware_sensors/files/nct6779.conf
    - template: jinja

/etc/sensors.d/nct6798.conf:
  file.managed:
    - source: salt://maintenance/hardware_sensors/files/nct6798.conf
    - template: jinja

set sensor limits:
  cmd.run:
    - name: sensors -s
    - onchanges:
      - file: /etc/sensors.d/nct6779.conf
      - file: /etc/sensors.d/nct6798.conf
{% endif %}
{% endfor %}

/etc/cron.hourly/sensors_check:
  file.managed:
    - source: salt://maintenance/hardware_sensors/files/sensors_check.sh
    - mode: 755
