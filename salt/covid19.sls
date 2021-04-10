{% from 'lib.sls' import create_user, set_firewall %}

covid19-prerequisites:
  pkg.installed:
    - pkgs:
      - libpq-dev # https://www.psycopg.org/install/

# Pillar data does not set branches. Branches must be manually set to deploy apps. To deploy both apps:
#
# ./run.py 'covid19-dev' state.apply pillar='{"python_apps":{"covid19admin":{"git":{"branch":"BRANCH_NAME"}}},"react_apps":{"covid19public":{"git":{"branch":"BRANCH_NAME"}}}}'

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

{{ create_user(backend_entry.user, authorized_keys=pillar.ssh.covid19admin) }}
{{ create_user(frontend_entry.user, authorized_keys=pillar.ssh.covid19) }}

{% if 'branch' in pillar.python_apps.covid19admin.git %}
pkill celery:
  cmd.run:
    - name: pkill celery
    - runas: {{ backend_entry.user }}
{% endif %}
