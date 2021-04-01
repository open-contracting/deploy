{% from 'lib.sls' import create_user, set_firewall %}

covid19-prerequisites:
  pkg.installed:
    - pkgs:
      - libpq-dev # https://www.psycopg.org/install/

# Pillar data does not set branches. Branches must be manually set to deploy apps. To deploy both apps:
#
# ./run.py 'covid19-dev' state.apply pillar='{"python_apps":{"covid19admin":{"git":{"branch":"BRANCH_NAME"}}},"react_apps":{"covid19public":{"git":{"branch":"BRANCH_NAME"}}}}'

{% if 'branch' in pillar.python_apps.covid19admin.git or 'branch' in pillar.react_apps.covid19public.git %}
include:
{% endif %}
{% if 'branch' in pillar.python_apps.covid19admin.git %}
  - python_apps
{% endif %}
{% if 'branch' in pillar.react_apps.covid19public.git %}
  - react_apps
{% endif %}

{{ set_firewall("PUBLIC_SSH") }}

{% set frontend_entry = pillar.react_apps.covid19public %}
{% set backend_entry = pillar.python_apps.covid19admin %}

{{ create_user(frontend_entry.user, authorized_keys=pillar.ssh.covid19) }}
{{ create_user(backend_entry.user, authorized_keys=pillar.ssh.covid19admin) }}
