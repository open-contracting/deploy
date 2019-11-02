# pillar.name is used to name files in:
#
# - /etc/apache2/sites-available/
# - /etc/apache2/sites-enabled/
# - /etc/uwsgi/apps-available/
# - /etc/uwsgi/apps-enabled/
#
# and to name Django-related IDs.

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
        - python3-pip
        - python-virtualenv
        - uwsgi-plugin-python3
      - watch_in:
        - service: apache2
        - service: uwsgi

{% set djangodir = '/home/' + pillar.user + '/' + pillar.name + '/' %}

{% set extracontext %}
djangodir: {{ djangodir }}
{% endset %}

{{ apache('django.conf',
    name=pillar.name + '.conf',
    servername=pillar.apache.servername,
    serveraliases=pillar.apache.serveraliases,
    https=pillar.apache.https,
    extracontext=extracontext) }}

{{ uwsgi('django.ini',
    name=pillar.name + '.ini',
    extracontext=extracontext) }}

{{ django(pillar.name,
    user=pillar.user,
    giturl=pillar.git.url,
    branch=pillar.git.branch,
    djangodir=djangodir,
    app=pillar.django.app,
    compilemessages=pillar.django.compilemessages) }}
