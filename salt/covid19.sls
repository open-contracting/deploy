{% from 'lib.sls' import create_user, set_firewall %}

{{ set_firewall("PUBLIC_SSH") }}

include:
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