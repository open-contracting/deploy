user: ocdskit-web
name: ocdskit-web
apache:
  https: force
  servername: toucan.open-contracting.org
git:
  url: https://github.com/open-contracting/toucan.git
django:
  app: ocdstoucan
  env:
    ALLOWED_HOSTS: toucan.open-contracting.org
