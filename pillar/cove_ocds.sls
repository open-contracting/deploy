python_apps:
  cove: # adds to cove.sls
    git:
      url: https://github.com/open-contracting/cove-ocds.git
    django:
      env:
        ALLOWED_HOSTS: .standard.open-contracting.org,.ocp02.open-contracting.org
        PIWIK_SITE_ID: '20'
        # HOTJAR_ID: 1501232
        # HOTJAR_SV: 6
        # HOTJAR_DATE_INFO: "4th March to 30th September 2020"
    apache:
      servername: ocp02.open-contracting.org
