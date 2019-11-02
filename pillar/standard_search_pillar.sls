user: standard-search
name: ocds-search
apache:
  https: both
  serveraliases: ['www.live.standard-search.opencontracting.uk0.bigv.io']
  servername: standard-search.open-contracting.org
  assets_base_url: ''
git:
  url: https://github.com/OpenDataServices/standard-search.git
  branch: master
django:
  app: standardsearch
  compilemessages: False
  env:
    DEBUG: 'False'
    LANG: en_US.utf8
    ALLOWED_HOSTS: standard-search.open-contracting.org,www.live.standard-search.opencontracting.uk0.bigv.io
