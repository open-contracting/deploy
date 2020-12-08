python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-oc4ids.git
    django:
      env:
        ALLOWED_HOSTS: .standard.open-contracting.org,.ocp01.open-contracting.org
        PIWIK_SITE_ID: '22'
    apache:
      servername: ocp01.open-contracting.org
      assets_base_url: /infrastructure
