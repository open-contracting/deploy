python_apps:
  covid19admin:
    django:
      env:
        ALLOWED_HOSTS: admin.covid19.development.opencontracting.uk0.bigv.io,covid19.development.opencontracting.uk0.bigv.io,www.covid19.development.opencontracting.uk0.bigv.io,localhost,127.0.0.1
        CORS_ORIGIN_WHITELIST: https://covid19.development.opencontracting.uk0.bigv.io,https://www.covid19.development.opencontracting.uk0.bigv.io
    apache:
      servername: admin.covid19.development.opencontracting.uk0.bigv.io

react_apps:
  covid19public:
    apache:
      servername: covid19.development.opencontracting.uk0.bigv.io
      serveraliases: ['www.covid19.development.opencontracting.uk0.bigv.io']
    env:
      REACT_APP_API_URL: https://admin.covid19.development.opencontracting.uk0.bigv.io
