{% from 'lib.sls' import apache, virtualenv %}

{% set enable_uwsgi = pillar.python_apps.values()|selectattr('uwsgi', 'defined')|first|default %}
{% set enable_apache = pillar.python_apps.values()|selectattr('apache', 'defined')|first|default %}

include:
{% if enable_uwsgi %}
  - uwsgi
{% endif %}
{% if enable_apache %}
  - apache
  - apache.modules.proxy_http
  - apache.modules.proxy_uwsgi
{% endif %}
  - python.virtualenv

# Inspired by the Apache formula, which loops over sites to configure. See example in readme.
# https://github.com/saltstack-formulas/apache-formula
# https://github.com/saltstack-formulas/apache-formula/blob/master/apache/config/register_site.sls
{% for name, entry in pillar.python_apps.items() %}

# A user might run multiple apps, so the user is not created here.
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set context = {'name': name, 'entry': entry, 'appdir': directory} %}

{{ entry.git.url }}:
  git.latest:
    - name: {{ entry.git.url }}
    - user: {{ entry.user }}
    - force_fetch: True
    - force_reset: True
    - branch: {{ entry.git.branch }}
    - rev: {{ entry.git.branch }}
    - target: {{ directory }}
    - require:
      - pkg: git
      - user: {{ entry.user }}_user_exists

# Note: {{ directory }}-requirements will run if git changed (not only if requirements changed), and uwsgi will be reloaded.
{{ virtualenv(directory, entry.user, {'git': entry.git.url}, {'git': entry.git.url}, 'uwsgi') }}

{% for filename, source in entry.config|items %}
{{ userdir }}/.config/{{ filename }}:
  file.managed:
    - source: {{ source }}
    - template: jinja
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists
{% endfor %}{# config #}

{% if 'django' in entry %}
{{ directory }}-migrate:
  cmd.run:
    - name: . .ve/bin/activate; python manage.py migrate --settings {{ entry.django.app }}.settings --noinput
    - runas: {{ entry.user }}
    - env: {{ entry.django.env|yaml }}
    - cwd: {{ directory }}
    - require:
      - cmd: {{ directory }}-requirements
    - onchanges:
      - git: {{ entry.git.url }}

{{ directory }}-collectstatic:
  cmd.run:
    - name: . .ve/bin/activate; python manage.py collectstatic --settings {{ entry.django.app }}.settings --noinput
    - runas: {{ entry.user }}
    - env: {{ entry.django.env|yaml }}
    - cwd: {{ directory }}
    - require:
      - cmd: {{ directory }}-requirements
    - onchanges:
      - git: {{ entry.git.url }}

{% if entry.django.get('compilemessages') %}
{{ directory }}-compilemessages:
  pkg.installed:
    - name: gettext
  cmd.run:
    # Django 3.0 adds --ignore: https://docs.djangoproject.com/en/3.2/releases/3.0/#management-commands
    - name: . .ve/bin/activate; python manage.py compilemessages --settings {{ entry.django.app }}.settings --ignore=.ve
    - runas: {{ entry.user }}
    - env: {{ entry.django.env|yaml }}
    - cwd: {{ directory }}
    - output_loglevel: warning
    - require:
      - cmd: {{ directory }}-requirements
    - onchanges:
      - git: {{ entry.git.url }}
{% endif %}
{% endif %}{# django #}

{% if 'uwsgi' in entry %}
/etc/uwsgi/apps-available/{{ entry.git.target }}.ini:
  file.managed:
    - source: salt://uwsgi/files/{{ entry.uwsgi.configuration }}.ini
    - template: jinja
    - context: {{ context|yaml }}
    - makedirs: True
    - watch_in:
      - service: uwsgi

/etc/uwsgi/apps-enabled/{{ entry.git.target }}.ini:
  file.symlink:
    - target: /etc/uwsgi/apps-available/{{ entry.git.target }}.ini
    - makedirs: True
    - require:
      - file: /etc/uwsgi/apps-available/{{ entry.git.target }}.ini
    - watch_in:
      - service: uwsgi
{% endif %}{# uwsgi #}

{% if 'apache' in entry %}
{{ apache(entry.git.target, entry.apache, context=context) }}
{% endif %}

{% endfor %}
