{% from 'lib.sls' import logrotate %}

# Some configurations use `postrotate /usr/lib/rsyslog/rsyslog-rotate`, so rsyslog is required.
include:
  - core.rsyslog

{% for filename, entry in salt['pillar.get']('logrotate:conf', {})|items %}
{{ logrotate(filename, entry) }}
{% endfor %}
