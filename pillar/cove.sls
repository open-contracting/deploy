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
        VALIDATION_ERROR_LOCATIONS_LENGTH: 100
        # https://github.com/requests-cache/requests-cache/blob/main/requests_cache/policy/expiration.py
        REQUESTS_CACHE_EXPIRE_AFTER: 0 # EXPIRE_IMMEDIATELY
    apache:
      configuration: django
      context:
        content: |
          ErrorDocument 500 "<h2>Sorry, something went wrong.</h2> <p>Sometimes this happens because the input file is too big - maybe try again with a smaller sample.</p><p>Please file a <a href=\"https://github.com/open-contracting/cove-ocds/issues/new\">GitHub issue</a> or email <a href=\"mailto:data@open-contracting.org\">data@open-contracting.org</a> if this problem persists.</p>"
    uwsgi:
      configuration: django
      harakiri: 1800 # 30 min
      cheaper: 50
      cheaper-initial: 50
      workers: 100
      threads: 1
      stats: /home/cove/stats.sock
