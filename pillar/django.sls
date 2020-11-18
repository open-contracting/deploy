# Each Django app must set, at minimum, the variables that are commented out, in an app-specific Pillar file.

# user:
# name:
apache:
  # https: force | certonly
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
    DJANGO_ENV: production
    # ALLOWED_HOSTS:
