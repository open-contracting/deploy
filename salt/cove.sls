# See https://cove.readthedocs.io/en/latest/deployment/
{% from 'lib.sls' import createuser, apache, uwsgi, django %}

{% set user = 'cove' %}
{{ createuser(user) }}

{% set giturl = 'https://github.com/OpenDataServices/cove.git' %}

# libapache2-mod-wsgi-py3
# gettext

include:
  - core
  - apache
  - uwsgi
{% if 'https' in pillar.cove %}  - letsencrypt{% endif %}

cove-deps:
    apache_module.enabled:
      - name: proxy proxy_uwsgi
      - watch_in:
        - service: apache2
    pkg.installed:
      - pkgs:
        - libapache2-mod-proxy-uwsgi
        - python-pip
        - python-virtualenv
        - uwsgi-plugin-python3
        - gettext
      - watch_in:
        - service: apache2
        - service: uwsgi

remoteip:
    apache_module.enabled:
      - watch_in:
        - service: apache2

{% macro cove(name, giturl, branch, djangodir, user, uwsgi_port, servername, app, assets_base_url, schema_url_ocds=None) %}


{% set extracontext %}
djangodir: {{ djangodir }}
{% if grains['osrelease'] == '16.04' %}
uwsgi_port: null
{% else %}
uwsgi_port: {{ uwsgi_port }}
{% endif %}
branch: {{ branch }}
app: {{ app }}
bare_name: {{ name }}
assets_base_url: {{ assets_base_url }}
{% if schema_url_ocds %}
schema_url_ocds: {{ schema_url_ocds }}
{% else %}
schema_url_ocds: null
{% endif %}
{% endset %}

{% if 'https' in pillar.cove %}
{{ apache(user+'.conf',
    name=name+'.conf',
    extracontext=extracontext,
    servername=servername,
    serveraliases=[ branch+'.'+grains.fqdn ],
    https=pillar.cove.https) }}
{% else %}
{{ apache(user+'.conf',
    name=name+'.conf',
    servername=servername,
    extracontext=extracontext) }}
{% endif %}

{{ uwsgi(user+'.ini',
    name=name+'.ini',
    extracontext=extracontext,
    port=uwsgi_port) }}

{{ django(name, user, giturl, branch, djangodir, 'pkg: cove-deps', app=app) }}

cd {{ djangodir }}; . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ app }}.settings SECRET_KEY="{{pillar.cove.secret_key}}" python manage.py expire_files:
  cron.present:
    - identifier: COVE_EXPIRE_FILES{% if name != 'cove' %}_{{ name }}{% endif %}
    - user: cove
    - minute: random
    - hour: 0
{% endmacro %}

MAILTO:
  cron.env_present:
    - value: code@opendataservices.coop
    - user: cove

{{ cove(
    name='cove',
    giturl=pillar.cove.giturl if 'giturl' in pillar.cove else giturl,
    branch=pillar.default_branch,
    djangodir='/home/'+user+'/cove/',
    uwsgi_port=pillar.cove.uwsgi_port,
    servername=pillar.cove.servername,
    assets_base_url=pillar.cove.assets_base_url,
    app=pillar.cove.app,
    user=user) }}


# We were having problems with the Raven library for Sentry on Ubuntu 18
# https://github.com/getsentry/raven-python/issues/1311
# Reloading the server manually after a short bit seemed to be the only fix.
# In testing, the code above seems not to always restart uwsgi anyway so we are happy putting this in.
# (Well, we are not happy about this situation at all, but we think this won't cause any problems at least.)
reload_uwsgi_service:
  cmd.run:
    - name: sleep 10; /etc/init.d/uwsgi reload
    - order: last
