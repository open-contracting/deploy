user: standard-search
name: ocds-search
apache:
  https: force
  servername: standard-search.open-contracting.org
git:
  url: https://github.com/open-contracting/standard-search.git
django:
  app: standardsearch
  compilemessages: False
  env:
    ALLOWED_HOSTS: standard-search.open-contracting.org
uwsgi:
  workers: 4
