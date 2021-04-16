{% from 'lib.sls' import create_user, set_firewall %}

covid19-prerequisites:
  pkg.installed:
    - pkgs:
      - libpq-dev # https://www.psycopg.org/install/

# Pillar data does not set branches. Branches must be manually set to deploy apps. To deploy both apps:
#
# ./run.py 'covid19-dev' state.apply pillar='{"python_apps":{"covid19admin":{"git":{"branch":"BRANCH_NAME"}}},"react_apps":{"covid19public":{"git":{"branch":"BRANCH_NAME"}}}}'

# See https://github.com/prerender/prerender-apache
include:
  - apache.modules.deflate
  - apache.modules.expires
  - apache.modules.headers
  - apache.modules.proxy_http
  - apache.modules.rewrite
{% if 'branch' in pillar.python_apps.covid19admin.git %}
  - python_apps
{% endif %}
{% if 'branch' in pillar.react_apps.covid19public.git %}
  - react_apps
{% endif %}

{{ set_firewall("PUBLIC_SSH") }}

{% set backend_entry = pillar.python_apps.covid19admin %}
{% set frontend_entry = pillar.react_apps.covid19public %}
{% set timestamp = salt['cmd.run']('date +%Y-%m-%d_%H:%M:%S') %}

{{ create_user(backend_entry.user, authorized_keys=pillar.ssh.covid19admin) }}
{{ create_user(frontend_entry.user, authorized_keys=pillar.ssh.covid19) }}

{% if 'branch' in pillar.python_apps.covid19admin.git %}
pkill celery:
  cmd.run:
    - name: pkill celery
    - runas: {{ backend_entry.user }}

  {% if pillar.ver_txt.enabled %}
    {% set userdir = '/home/' + backend_entry.user %}
    {% set static_dir = userdir + '/' + backend_entry.git.target + '/static' %}
    {% set directory = userdir + '/' + backend_entry.git.target %}

{{static_dir}}/ver.txt:
  file.managed:
    - contents: "branch: {{ backend_entry.git.branch }} || commit_hash: {{ salt['cmd.shell']('cd ' + directory + '&& git rev-parse --verify '+ backend_entry.git.branch ) }} || time: {{ timestamp }}"
  {% endif %}

{% endif %}

covid19-pipinstall:
  pkg.installed:
    - name: python3-pip
  pip.installed:
    - name: flower==0.9.5
    - user: {{ backend_entry.user }}
    - bin_env: /usr/bin/pip3
    - require:
      - pkg: covid19-pipinstall

covid19-pip-path:
  file.append:
    - name: /home/{{ backend_entry.user }}/.bashrc
    - text: "export PATH=\"/home/{{ backend_entry.user }}/.local/bin/:$PATH\""
