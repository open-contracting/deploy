python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-oc4ids.git
    django:
      env:
        ALLOWED_HOSTS: .standard.open-contracting.org,.oc4ids.opencontracting.uk0.bigv.io
        PIWIK_SITE_ID: '22'
    apache:
      servername: cove-live.oc4ids.opencontracting.uk0.bigv.io
      assets_base_url: /infrastructure
