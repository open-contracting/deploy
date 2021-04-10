{% from 'lib.sls' import apache %}

include:
  - apache

{% for name, entry in pillar.react_apps.items() %}

# A user might run multiple apps, so the user is not created here.
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set builddir = userdir + '/releases' %}
{% set timestamp = salt['cmd.run']('date +%Y%m%d%H%M%S') %}
{% set appdir = userdir + '/current' %}
{% set context = {'name': name, 'entry': entry, 'appdir': appdir} %}

{{ builddir }}:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

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

{{ directory }}/.env:
  file.managed:
    - source: salt://react_apps/files/env
    - template: jinja
    - context: {{ context|yaml }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - git: {{ entry.git.url }}

{{ directory }}-yarn-install:
  cmd.run:
    - name: yarn
    - runas: {{ entry.user }}
    - cwd: {{ directory }}
    - require:
      - git: {{ entry.git.url }}
      - pkg: yarn
    - onchanges:
      - git: {{ entry.git.url }}

# This step can take minutes.
{{ directory }}-yarn-build:
  cmd.run:
    - name: yarn build && mv build {{ builddir }}/{{ timestamp }}
    - runas: {{ entry.user }}
    - env: {{ entry.env|yaml }}
    - cwd: {{ directory }}
    - require:
      - cmd: {{ directory }}-yarn-install
      - file: {{ directory }}/.env
      - file: {{ builddir }}
    - onchanges:
      - git: {{ entry.git.url }}

{{ appdir }}:
  file.symlink:
    - target: {{ builddir }}/{{ timestamp }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - cmd: {{ directory }}-yarn-build
    - require_in:
      - service: apache2

{% if 'apache' in entry %}
{{ apache(entry.git.target, entry.apache, context=context) }}
{% endif %}

{% if salt['pillar.get']('ver_txt:enabled') %}
{{ builddir }}/{{ timestamp }}/ver.txt:
  file.managed:
    - contents: |
        {{ entry.git.branch }} {{ salt['cmd.shell']('cd ' + directory + ' && git rev-parse --verify HEAD') }} {{ salt['cmd.run']('date +%Y-%m-%d_%H:%M:%S') }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - cmd: {{ directory }}-yarn-build
{% endif %}

{% endfor %}
