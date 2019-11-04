# Each Django app must set, at minimum, the variables that are commented out, in an app-specific Pillar file.

# user:
# name:
apache:
  # https: both | force | certonly
  # servername:
  serveraliases: []
  assets_base_url: ''
git:
  # url:
  branch: master
django:
  # app:
  compilemessages: True
  env:
    DEBUG: 'False'
    LANG: en_US.utf8
    # ALLOWED_HOSTS:
uwsgi:
  # If larger_limits is set to True, the app-specific Pillar file must set uwsgi.limit_as and uwsgi.harakiri.
  larger_limits: False
