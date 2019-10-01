
{% from 'lib.sls' import createuser, apache %}

include:
  - prometheus-client-common
  - apache
  - apache-proxy

# Note user variable is set in other prometheus-client-*.sls files too!
{% set user = 'prometheus-client' %}

########### Apache Reverse Proxy with password for security

{% set extracontext %}
user: {{ user }}
apache_port: {{ pillar.prometheus.client_port }}
{% endset %}

{{ apache('prometheus-client.conf',
    name='prometheus-client.conf',
    extracontext=extracontext,
    servername=pillar.prometheus.client_fqdn if pillar.prometheus.client_fqdn else 'prom-client.'+grains.fqdn ) }}

prometheus-client-apache-password:
  cmd.run:
    - name: rm /home/{{ user }}/htpasswd ; htpasswd -c -b /home/{{ user }}/htpasswd prom {{ pillar.prometheus.client_password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}

