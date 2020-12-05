# https://github.com/saltstack-formulas/rsyslog-formula/blob/master/rsyslog/init.sls
rsyslog:
  service.running:
    - name: rsyslog
    - enable: True

{% if salt['pillar.get']('rsyslog:conf') %}
# To create an rsyslog configuration, add the following data to a Pillar file:
#
# rsyslog:
#   conf:
#     CONF-NAME: SOURCE-NAME

{% for filename, source in pillar.rsyslog.conf.items() %}
/etc/rsyslog.d/{{ filename }}:
  file.managed:
    - source: salt://core/rsyslog/files/{{ source }}
    - watch_in:
      - service: rsyslog
{% endfor %}
{% endif %}
