{% from 'lib.sls' import createuser, apache %}

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

{% set extracontext %}
user: {{ user }}
{% endset %}

{{ apache('prometheus-client',
    name='prometheus-client',
    extracontext=extracontext,
    servername=pillar.prometheus.client_fqdn if pillar.prometheus.client_fqdn else 'prom-client.' + grains.fqdn,
    ports=[pillar.prometheus.client_port]) }}

prometheus-client-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus.client_password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}
