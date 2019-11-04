# See https://cove.readthedocs.io/en/latest/deployment/
{% from 'lib.sls' import createuser, apache, uwsgi, django %}

{{ createuser(pillar.user) }}

include:
  - apache-proxy
  - uwsgi

{{ pillar.user }}-deps:
    apache_module.enabled:
      - name: proxy proxy_uwsgi
      - watch_in:
        - service: apache2
    pkg.installed:
      - pkgs:
        - libapache2-mod-proxy-uwsgi
        - python-virtualenv
        - uwsgi-plugin-python3
        {% if pillar.django.compilemessages %}
        - gettext
        {% endif %}
      - watch_in:
        - service: apache2
        - service: uwsgi

{% set djangodir = '/home/' + pillar.user + '/' + pillar.name + '/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
{% endset %}

{{ apache(pillar.user + '.conf',
    name=pillar.name + '.conf',
    servername=pillar.apache.servername,
    serveraliases=pillar.apache.serveraliases,
    https=pillar.apache.https,
    extracontext=extracontext) }}

{{ uwsgi(pillar.user + '.ini',
    name=pillar.name + '.ini',
    extracontext=extracontext) }}

{{ django(pillar.name,
    user=pillar.user,
    giturl=pillar.git.url,
    branch=pillar.git.branch,
    djangodir=djangodir,
    app=pillar.django.app,
    compilemessages=pillar.django.compilemessages) }}

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
