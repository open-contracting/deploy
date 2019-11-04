user: cove
name: cove
apache:
  https: both
  servername: cove-live.oc4ids.opencontracting.uk0.bigv.io
  serveraliases: ['master.{{ grains.fqdn }}'] # should match git.branch
  assets_base_url: /infrastructure
git:
  url: https://github.com/open-contracting/cove-oc4ids.git
django:
  app: cove_project
  env:
    ALLOWED_HOSTS: .standard.open-contracting.org,.oc4ids.opencontracting.uk0.bigv.io
    GOOGLE_ANALYTICS_ID: UA-35677147-1
    PIWIK_URL: //mon.opendataservices.coop/piwik/
    PIWIK_SITE_ID: '22'
    PIWIK_DIMENSION_MAP: 'file_type=1,page_type=2,form_name=3,language=4,exit_language=5'
    PREFIX_MAP: ''
uwsgi:
  larger_limits: True
  limit_as: 12000 # 12 GB
  harakiri: 1800 # 30 min
