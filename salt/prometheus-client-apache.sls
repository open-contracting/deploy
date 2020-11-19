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

########### Apache Reverse Proxy with password for security

{% if pillar.prometheus.client_port == 80 %}
{{ configurefirewall("PUBLICHTTPSERVER") }}
{% elif pillar.prometheus.client_port == 7231 %}
{{ configurefirewall("PROMETHEUSCLIENTSERVER") }}
{% endif %}


{{ apache('prometheus-client',
    servername=pillar.prometheus.client_fqdn if pillar.prometheus.client_fqdn else 'prom-client.' + grains.fqdn,
    extracontext='user: ' + user,
    ports=[pillar.prometheus.client_port]) }}

prometheus-client-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus.client_password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}

