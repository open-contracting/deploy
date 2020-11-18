user: standard-search
name: ocds-search
apache:
  https: force
  servername: standard-search.open-contracting.org
  serveraliases: ['www.live.standard-search.opencontracting.uk0.bigv.io']
git:
  url: https://github.com/open-contracting/standard-search.git
django:
  app: standardsearch
  compilemessages: False
  env:
    ALLOWED_HOSTS: standard-search.open-contracting.org,www.live.standard-search.opencontracting.uk0.bigv.io
uwsgi:
  workers: 4
