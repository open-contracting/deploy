{% from 'lib.sls' import createuser, apache, set_firewall %}

{% if pillar.prometheus_node_exporter.port == 80 %}
{{ set_firewall("PUBLIC_PROMETHEUS_CLIENT") }}
{% elif pillar.prometheus_node_exporter.port == 7231 %}
{{ set_firewall("PRIVATE_PROMETHEUS_CLIENT") }}
{% endif %}

include:
  - apache.public
  - apache.modules.proxy_http
  - prometheus_node_exporter

# Note user variable is set in other prometheus_node_exporter State file, too!
{% set user = 'prometheus-client' %}

{{ apache('prometheus-client',
    servername=pillar.prometheus_node_exporter.fqdn if pillar.prometheus_node_exporter.fqdn else 'prom-client.' + grains['fqdn'],
    extracontext='user: ' + user,
    ports=[pillar.prometheus_node_exporter.port]) }}
