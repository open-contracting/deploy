python_apps:
  covid19admin:
    django:
      env:
        ALLOWED_HOSTS: admin.open-contracting.health,open-contracting.health,www.open-contracting.health,localhost,127.0.0.1
        CORS_ORIGIN_WHITELIST: https://open-contracting.health,https://www.open-contracting.health
    apache:
      servername: admin.open-contracting.health

react_apps:
  covid19public:
    apache:
      servername: open-contracting.health
      serveraliases: ['www.open-contracting.health']
    env:
      REACT_APP_API_URL: https://admin.open-contracting.health
      REACT_APP_FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
      REACT_APP_FATHOM_ANALYTICS_ID: LKQYBVCU
