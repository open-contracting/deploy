apache:
  public_access: True

python_apps:
  cove:
    user: cove
    git:
      branch: main
      target: cove
    django:
      app: cove_project
      compilemessages: True
      env:
        FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
        VALIDATION_ERROR_LOCATIONS_LENGTH: 100
    apache:
      configuration: django
      context:
        docs_ipv4: 5.28.62.151
        docs_ipv6: 2001:41c9:1:41c::151
    uwsgi:
      configuration: django
      harakiri: 1800 # 30 min
      cheaper: 50
      cheaper-initial: 50
      workers: 100
      threads: 1
      stats: /home/cove/stats.sock
