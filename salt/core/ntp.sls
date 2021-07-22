{% if grains['osrelease']|float >= 20.04 %}
# systemd-timesyncd should be installed by default unless the NTP set up code below has ran against server.
systemd-timesyncd:
  pkg.installed:
    - name: systemd-timesyncd
  service.running:
    - name: systemd-timesyncd
    - enable: True
    - require:
      - pkg: systemd-timesyncd

/etc/systemd/timesyncd.conf:
  file.replace:
    - pattern: "^#?NTP=.*"
    - repl: 'NTP=0.uk.pool.ntp.org 1.uk.pool.ntp.org 2.uk.pool.ntp.org 3.uk.pool.ntp.org/'
    - watch_in:
      - service: systemd-timesyncd

# Catch instances where ntp has been installed previously.
ntp:
  service.dead:
    - enable: False

{% else %}
systemd-timesyncd:
  service.dead:
    - enable: False

ntp:
  pkg.installed:
    - name: ntp
  service.running:
    - name: ntp
    - enable: True
    - require:
      - pkg: ntp

/etc/ntp.conf:
  file.replace:
    - pattern: "ubuntu.pool.ntp.org"
    - repl: "uk.pool.ntp.org"
    - require:
      - pkg: ntp
    - watch_in:
      - service: ntp
{% endif %}

# Set timezone to UTC.
UTC:
  timezone.system
