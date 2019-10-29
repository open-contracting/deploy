# Values used only on the Cove OCDS server
default_branch: 'master'
cove:
  servername: 'cove.live.cove.opencontracting.uk0.bigv.io'
  allowedhosts: '.cove.opencontracting.uk0.bigv.io,.standard.open-contracting.org'
  giturl: 'https://github.com/OpenDataServices/cove.git'
  app: cove_ocds
  assets_base_url: ''
  uwsgi_port: 3031
  piwik:
    url: '//mon.opendataservices.coop/piwik/'
    site_id: '20' 
    dimension_map: 'file_type=1,page_type=2,form_name=3,language=4,exit_language=5'
  google_analytics_id: 'UA-35677147-1'
  larger_uwsgi_limits: True
  uwsgi_as_limit: 12000
  uwsgi_harakiri: 1800
  https: 'yes'
  prefixmap: ''
