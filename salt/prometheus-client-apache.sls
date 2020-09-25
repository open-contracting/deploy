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

{% set extracontext %}
user: {{ user }}
apache_port: {{ pillar.prometheus.client_port }}
{% endset %}

{% if pillar.prometheus.client_port = 80 %}
{{ configurefirewall("PUBLICHTTPSERVER") }}
{% elif pillar.prometheus.client_port = 7231 %}
{{ configurefirewall("PROMETHEUSCLIENTACCESS=yes") }}
{% endif %}

{{ apache('prometheus-client.conf',
    name='prometheus-client.conf',
    extracontext=extracontext,
    servername=pillar.prometheus.client_fqdn if pillar.prometheus.client_fqdn else 'prom-client.' + grains.fqdn) }}

prometheus-client-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus.client_password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}
