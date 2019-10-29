# See https://cove.readthedocs.io/en/latest/deployment/
{% from 'lib.sls' import createuser, apache, uwsgi %}

{% set user = 'cove' %}
{{ createuser(user) }}

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

{% set name = 'cove' %}
{% set giturl = pillar.cove.giturl %}
{% set branch = pillar.default_branch %}
{% set djangodir = '/home/' + user + '/cove/' %}
{% set uwsgi_port = pillar.cove.uwsgi_port %}
{% set app = pillar.cove.app %}

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
assets_base_url: {{ pillar.cove.assets_base_url }}
schema_url_ocds: null
{% endset %}

{{ apache(user + '.conf',
    name=name + '.conf',
    extracontext=extracontext,
    servername=pillar.cove.servername,
    serveraliases=[ branch + '.' + grains.fqdn ],
    https=pillar.cove.https) }}

{{ uwsgi(user + '.ini',
    name=name + '.ini',
    extracontext=extracontext,
    port=uwsgi_port) }}

{{ giturl }}{{ djangodir }}:
  git.latest:
    - name: {{ giturl }}
    - rev: {{ branch }}
    - target: {{ djangodir }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git
    - watch_in:
      - service: uwsgi

# We have seen different permissions on different servers and we have seen bugs arise due to problems with the permissions.
# Make sure the user and permissions are set correctly for the media folder and all it's contents!
# (This in itself won't make sure permissions are correct on new files, but it will sort any existing problems)
{{ djangodir }}/media:
  file.directory:
    - name: {{ djangodir }}/media
    - user: {{ user }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - mode

{{ djangodir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - requirements: {{ djangodir }}requirements.txt
    - require:
      - pkg: cove-deps
      - git: {{ giturl }}{{ djangodir }}
      - file: set_lc_all # required to avoid unicode errors for the "schema" library
    - watch_in:
      - service: apache2

migrate-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ app }}.settings python manage.py migrate --noinput
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

compilemessages-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ app }}.settings  python manage.py compilemessages
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

collectstatic-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ app }}.settings  python manage.py collectstatic --noinput
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

{{ djangodir }}static/:
  file.directory:
    - user: {{ user }}
    - file_mode: 644
    - dir_mode: 755
    - recurse:
      - mode
    - require:
      - cmd: collectstatic-{{ name }}

{{ djangodir }}:
  file.directory:
    - dir_mode: 755
    - require:
      - cmd: collectstatic-{{ name }}

cd {{ djangodir }}; . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ app }}.settings SECRET_KEY="{{ pillar.cove.secret_key }}" python manage.py expire_files:
  cron.present:
    - identifier: COVE_EXPIRE_FILES{% if name != 'cove' %}_{{ name }}{% endif %}
    - user: cove
    - minute: random
    - hour: 0

MAILTO:
  cron.env_present:
    - value: code@opendataservices.coop
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
