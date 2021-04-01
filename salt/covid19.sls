{% from 'lib.sls' import create_user, set_firewall %}

{{ set_firewall("PUBLIC_SSH") }}

covid19-prerequisites:
  pkg.installed:
    - pkgs:
      - libpq-dev # https://www.psycopg.org/install/

# Pillar data does not set branches. Branches must be manually set to deploy apps. To deploy both apps:
#
# ./run.py 'covid19-dev' state.apply pillar='{"python_apps":{"covid19admin":{"git":{"branch":"BRANCH_NAME"}}},"react_apps":{"covid19public":{"git":{"branch":"BRANCH_NAME"}}}}'

{% if salt['pillar.get']('python_apps:covid19admin:git:branch') or salt['pillar.get']('react_apps:covid19public:git:branch') %}
include:
{% endif %}
{% if 'branch' in pillar.python_apps.covid19admin.git %}
  - python_apps
{% endif %}
{% if 'branch' in pillar.react_apps.covid19public.git %}
  - react_apps
{% endif %}

{% if 'branch' in pillar.react_apps.covid19public.git %}
  {% set frontend_entry = pillar.react_apps.covid19public %}
  {{ create_user(frontend_entry.user, authorized_keys=pillar.ssh.covid19) }}
{% endif %}

{% if 'branch' in pillar.python_apps.covid19admin.git %}
  {% set backend_entry = pillar.python_apps.covid19admin %}
  {{ create_user(backend_entry.user, authorized_keys=pillar.ssh.covid19admin) }}
{% endif %}