{% from 'lib.sls' import createuser, apache, configurefirewall %}

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

{% if pillar.prometheus_client.port == 80 %}
{{ configurefirewall("PUBLICHTTPSERVER") }}
{% elif pillar.prometheus_client.port == 7231 %}
{{ configurefirewall("PROMETHEUSCLIENTSERVER") }}
{% endif %}

## Apache reverse proxy with password for security

{{ user }}-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus_client.password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}

{{ apache('prometheus-client',
    servername=pillar.prometheus_client.fqdn if pillar.prometheus_client.fqdn else 'prom-client.' + grains.fqdn,
    extracontext='user: ' + user,
    ports=[pillar.prometheus_client.port]) }}
