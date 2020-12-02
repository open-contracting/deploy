# pillar.name is used to name files in:
#
# - /etc/apache2/sites-available/
# - /etc/apache2/sites-enabled/
# - /etc/uwsgi/apps-available/
# - /etc/uwsgi/apps-enabled/
#
# and to name Django-related IDs.

{% from 'lib.sls' import createuser, apache, uwsgi %}

{{ createuser(pillar.user) }}

include:
  - apache.public
  - apache.modules.proxy_http
  - apache.modules.proxy_uwsgi
  - uwsgi

django-deps:
  pkg.installed:
    - pkgs:
      - python-virtualenv
      - uwsgi-plugin-python3
      {% if pillar.django.compilemessages %}
      - gettext
      {% endif %}
    - watch_in:
      - service: apache2
      - service: uwsgi

{% set djangodir = '/home/' + pillar.user + '/' + pillar.name + '/' %}

{{ apache('django',
    name=pillar.name,
    servername=pillar.apache.servername,
    serveraliases=pillar.apache.serveraliases,
    https=pillar.apache.https,
    extracontext='djangodir: ' + djangodir) }}

{{ uwsgi('django', name=pillar.name, appdir=djangodir) }}

{{ pillar.git.url }}{{ djangodir }}:
  git.latest:
    - name: {{ pillar.git.url }}
    - rev: {{ pillar.git.branch }}
    - target: {{ djangodir }}
    - user: {{ pillar.user }}
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git

# We have seen different permissions on different servers, and we have seen bugs arise as a result.
# (This won't ensure permissions are correct on new files, but it will fix any existing problems.)
{{ djangodir }}media:
  file.directory:
    - name: {{ djangodir }}media
    - user: {{ pillar.user }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - mode

{{ djangodir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ pillar.user }}
    - system_site_packages: False
    - pip_pkgs:
        - pip-tools
    - require:
      - pkg: django-deps
      - git: {{ pillar.git.url }}{{ djangodir }}
      - file: set_lc_all # required to avoid unicode errors for the "schema" library

pip_install_requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q --pip-args "--exists-action w"
    - runas: {{ pillar.user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ pillar.git.url }}{{ djangodir }}
    - watch_in:
      - service: uwsgi

migrate:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ pillar.django.app }}.settings python manage.py migrate --noinput
    - runas: {{ pillar.user }}
    - cwd: {{ djangodir }}
    - require:
      - cmd: pip_install_requirements
    - onchanges:
      - git: {{ pillar.git.url }}{{ djangodir }}

{% if pillar.django.compilemessages %}
compilemessages:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ pillar.django.app }}.settings python manage.py compilemessages
    - runas: {{ pillar.user }}
    - cwd: {{ djangodir }}
    - require:
      - cmd: pip_install_requirements
    - onchanges:
      - git: {{ pillar.git.url }}{{ djangodir }}
{% endif %}

collectstatic:
  cmd.run:
    - name: . .ve/bin/activate; DJANGO_SETTINGS_MODULE={{ pillar.django.app }}.settings python manage.py collectstatic --noinput
    - runas: {{ pillar.user }}
    - cwd: {{ djangodir }}
    - require:
      - cmd: pip_install_requirements
    - onchanges:
      - git: {{ pillar.git.url }}{{ djangodir }}

{{ djangodir }}static/:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - recurse:
      - mode
    - require:
      - cmd: collectstatic
    - user: {{ pillar.user }}
    - group: {{ pillar.user }}

{{ djangodir }}:
  file.directory:
    - dir_mode: 755
    - require:
      - cmd: collectstatic
    - user: {{ pillar.user }}
    - group: {{ pillar.user }}
