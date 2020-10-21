apache:
  servername: cove-live.oc4ids.opencontracting.uk0.bigv.io
  assets_base_url: /infrastructure
git:
  url: https://github.com/open-contracting/cove-oc4ids.git
django:
  app: cove_project
  env:
    ALLOWED_HOSTS: .standard.open-contracting.org,.oc4ids.opencontracting.uk0.bigv.io
    PIWIK_SITE_ID: '22'
uwsgi:
  limit-as: 6000
  harakiri: 1800
  max-requests: 1024
  reload-on-as: 250
  cheaper: 2
  cheaper-initial: 2
  workers: 100
  threads: 1
