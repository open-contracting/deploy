# Values used only on the Cove OC4IDS server
default_branch: 'master'
cove:
  app: cove_project
  assets_base_url: '/infrastructure'
  uwsgi_port: 3032  # Can't use default 3031 on Ubuntu 18 till https://github.com/unbit/uwsgi/issues/1491 is fixed
  piwik:
    url: '//mon.opendataservices.coop/piwik/'
    site_id: '22'
    dimension_map: 'file_type=1,page_type=2,form_name=3,language=4,exit_language=5'
  google_analytics_id: 'UA-35677147-1'
  giturl: 'https://github.com/open-contracting/cove-oc4ids.git'
  allowedhosts: '.opendataservices.coop'
  larger_uwsgi_limits: True
  uwsgi_as_limit: 12000
  uwsgi_harakiri: 1800
  https: 'yes'
  servername: 'oc4ids.cove.live.opendataservices.coop'
  prefixmap: ''


