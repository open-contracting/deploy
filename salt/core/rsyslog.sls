# https://github.com/saltstack-formulas/rsyslog-formula/blob/master/rsyslog/init.sls
rsyslog:
  service.running:
    - name: rsyslog
    - enable: True
