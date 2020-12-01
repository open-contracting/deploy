{% from 'lib.sls' import createuser, apache, set_firewall %}

{% if pillar.prometheus_client.port == 80 %}
{{ set_firewall("PUBLIC_PROMETHEUS_CLIENT") }}
{% elif pillar.prometheus_client.port == 7231 %}
{{ set_firewall("PRIVATE_PROMETHEUS_CLIENT") }}
{% endif %}

include:
  - prometheus-client-common
  - apache

prometheus-client modules:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http

# Note user variable is set in other prometheus-client-*.sls files too!
{% set user = 'prometheus-client' %}
{% set userdir = '/home/' + user %}

## Apache reverse proxy with password for security

htpasswd-{{ user }}:
  webutil.user_exists:
    - name: prom
    - password: {{ pillar.prometheus_client.password }}
    - htpasswd_file: {{ userdir }}/htpasswd
    - runas: {{ user }}
    - update: True

{{ apache('prometheus-client',
    servername=pillar.prometheus_client.fqdn if pillar.prometheus_client.fqdn else 'prom-client.' + grains.fqdn,
    extracontext='user: ' + user,
    ports=[pillar.prometheus_client.port]) }}
