include:
  - django

# See https://cove.readthedocs.io/en/latest/deployment/

{% set djangodir = '/home/' + pillar.user + '/' + pillar.name + '/' %}

remoteip:
    apache_module.enabled:
      - watch_in:
        - service: apache2

cd {{ djangodir }}; . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ pillar.django.app }}.settings SECRET_KEY="{{ pillar.django.env.SECRET_KEY|replace('%', '\%') }}" python manage.py expire_files:
  cron.present:
    - identifier: COVE_EXPIRE_FILES
    - user: cove
    - minute: random
    - hour: 0

MAILTO:
  cron.env_present:
    - value: sysadmin@open-contracting.org,code@opendataservices.coop
    - user: cove

# We were having problems with the Raven library for Sentry on Ubuntu 18
# https://github.com/getsentry/raven-python/issues/1311
# Reloading the server manually after a short bit seemed to be the only fix.
# In testing, the code above seems not to always restart uwsgi anyway so we are happy putting this in.
# (Well, we are not happy about this situation at all, but we think this won't cause any problems at least.)
reload_uwsgi_service:
  cmd.run:
    - name: sleep 10; /etc/init.d/uwsgi reload
    - order: last
