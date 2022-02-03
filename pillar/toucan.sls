apache:
  public_access: True

python_apps:
  toucan:
    user: ocdskit-web
    git:
      url: https://github.com/open-contracting/toucan.git
      branch: main
      target: ocdskit-web
    django:
      app: ocdstoucan
      compilemessages: True
      env:
        ALLOWED_HOSTS: toucan.open-contracting.org
        FATHOM_ANALYTICS_DOMAIN: kite.open-contracting.org
        FATHOM_ANALYTICS_ID: UECNCPJN
    apache:
      configuration: django
      servername: toucan.open-contracting.org
    uwsgi:
      configuration: django
