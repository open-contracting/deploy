{% from 'lib.sls' import createuser, apache, set_firewall %}

{% if pillar.prometheus_client.port == 80 %}
{{ set_firewall("PUBLIC_PROMETHEUS_CLIENT") }}
{% elif pillar.prometheus_client.port == 7231 %}
{{ set_firewall("PRIVATE_PROMETHEUS_CLIENT") }}
{% endif %}

include:
  - apache.public
  - apache.modules.proxy_http
  - prometheus-client-common

# Note user variable is set in other prometheus-client-*.sls files too!
{% set user = 'prometheus-client' %}

{{ apache('prometheus-client',
    servername=pillar.prometheus_client.fqdn if pillar.prometheus_client.fqdn else 'prom-client.' + grains.fqdn,
    extracontext='user: ' + user,
    ports=[pillar.prometheus_client.port]) }}
