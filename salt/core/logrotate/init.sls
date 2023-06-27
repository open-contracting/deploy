# Some configurations use `postrotate /usr/lib/rsyslog/rsyslog-rotate`, so rsyslog is required.
include:
  - core.rsyslog

{% for filename, source in salt['pillar.get']('logrotate:conf', {}).items() %}
/etc/logrotate.d/{{ filename }}:
  file.managed:
    - source: salt://core/logrotate/files/{{ source }}
{% endfor %}
