# Some configurations use `postrotate /usr/lib/rsyslog/rsyslog-rotate`, so rsyslog is required.
include:
  - core.rsyslog

{% for filename, entry in salt['pillar.get']('logrotate:conf', {}).items() %}
/etc/logrotate.d/{{ filename }}:
  file.managed:
    - source: salt://core/logrotate/files/{{ entry.source }}
{% if 'context' in entry %}
    - template: jinja
    - context: {{ entry.context|yaml }}
{% endif %}
{% endfor %}
