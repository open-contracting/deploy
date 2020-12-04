# Some configurations use `postrotate /usr/lib/rsyslog/rsyslog-rotate`.
include:
  - core.rsyslog

{% if salt['pillar.get']('logrotate:conf') %}
# To create a logrotate configuration, add the following data to a Pillar file:
#
# logrotate:
#   conf:
#     CONF-NAME: SOURCE-NAME

{% for name, source in pillar.logrotate.conf.items() %}
/etc/logrotate.d/{{ name }}:
  file.managed:
    - source: salt://core/logrotate/files/{{ source }}
{% endfor %}
{% endif %}
