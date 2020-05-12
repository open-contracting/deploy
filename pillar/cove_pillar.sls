user: cove
name: cove
apache:
  https: both
  serveraliases: ['master.{{ grains.fqdn }}'] # should match git.branch
django:
  env:
    GOOGLE_ANALYTICS_ID: UA-35677147-1
    PIWIK_URL: //mon.opendataservices.coop/piwik/
    PIWIK_DIMENSION_MAP: 'file_type=1,page_type=2,form_name=3,language=4,exit_language=5'
    PREFIX_MAP: ''
uwsgi:
  larger_limits: True
  limit_as: 6000 # 6 GB
  harakiri: 1800 # 30 min
