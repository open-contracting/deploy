apache:
  servername: cove.live3.cove.opencontracting.uk0.bigv.io
git:
  url: https://github.com/open-contracting/cove-ocds.git
django:
  app: cove_project
  env:
    ALLOWED_HOSTS: .standard.open-contracting.org,.cove.opencontracting.uk0.bigv.io
    PIWIK_SITE_ID: '20'
    # HOTJAR_ID: 1501232
    # HOTJAR_SV: 6
    # HOTJAR_DATE_INFO: "4th March to 30th September 2020"
uwsgi:
  limit-as: 6000
  harakiri: 1800
  max-requests: 1024
  reload-on-as: 250
  cheaper: 2
  cheaper-initial: 2
  workers: 100
  threads: 1
