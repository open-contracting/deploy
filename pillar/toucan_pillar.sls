user: ocdskit-web
name: ocdskit-web
apache:
  https: force
  serveraliases: []
  servername: toucan.open-contracting.org
git:
  url: https://github.com/open-contracting/toucan.git
  branch: master
django:
  app: ocdstoucan
  compilemessages: true
  env:
    DEBUG: 'False'
    LANG: en_US.utf8
    ALLOWED_HOSTS: toucan.open-contracting.org
