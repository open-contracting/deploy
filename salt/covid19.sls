{% from 'lib.sls' import create_user, set_firewall %}
{{ set_firewall("PUBLIC_SSH") }}

include:
{% if salt['pillar.get']('python_apps:covid19admin:git:branch') %}
  - python_apps
{% endif %}

{% if salt['pillar.get']('react_apps:covid19public:git:branch') %}
  - react_apps
{% endif %}

{% if salt['pillar.get']('react_apps:covid19public:git:branch') %}
  {% set frontend_entry = pillar.react_apps.covid19public %}
  {{ create_user(frontend_entry.user, authorized_keys=pillar.ssh.covid19) }}
{% endif %}

{% if salt['pillar.get']('python_apps:covid19admin:git:branch') %}
  {% set backend_entry = pillar.python_apps.covid19admin %}
  {{ create_user(backend_entry.user, authorized_keys=pillar.ssh.covid19admin) }}
{% endif %}