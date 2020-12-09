{% from 'lib.sls' import prometheus_service, set_firewall %}

{% set user = pillar.prometheus.node_exporter.user %}

{{ set_firewall("PRIVATE_PROMETHEUS_CLIENT") }}
{{ set_firewall("PROMETHEUS_IPV4", pillar.firewall.prometheus_ipv4) }}
{{ set_firewall("PROMETHEUS_IPV6", pillar.firewall.prometheus_ipv6) }}

# The private key and certificate request were created with:
#
#     openssl req -nodes -x509 -days 3650 -out node_exporter.pem -newkey rsa:2048 -keyout node_exporter.key -subj "/CN=*.open-contracting.org"
#
# To re-generate the certificate request:
#
#     openssl req -nodes -x509 -days 3650 -out node_exporter.pem -new -key node_exporter.key -subj "/CN=*.open-contracting.org"
#
# The same self-signed certificate is used on multiple machines. Since it's only for Node Exporter, that's OK.
#
# https://developpaper.com/add-authentication-to-prometheus-node-exporter/
# https://www.openssl.org/docs/manmaster/man1/openssl-req.html
/home/{{ user }}/node_exporter.key:
  file.managed:
    - source: salt://private/keys/node_exporter.key
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - require:
      - user: {{ user }}_user_exists
    - watch_in:
      - service: prometheus-node-exporter

{{ prometheus_service('node_exporter') }}

## Smartmontools

{% if salt['pillar.get']('prometheus:node_exporter:smartmon') %}
smartmontools:
  pkg.installed

/home/{{ user }}/node-exporter-textfile-directory:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists

/home/{{ user }}/node-exporter-textfile-collector-scripts:
  git.latest:
    - name: https://github.com/prometheus-community/node-exporter-textfile-collector-scripts
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: /home/{{ user }}/node-exporter-textfile-collector-scripts
    - require:
      - pkg: git
      - user: {{ user }}_user_exists

/home/prometheus-client/node-exporter-textfile-collector-scripts/smartmon.sh > /home/{{ user }}/node-exporter-textfile-directory/smartmon.sh.prom:
  cron.present:
    - identifier: PROMETHEUS_CLIENT_TEXTFILE_COLLECTOR_SMARTMON
    # This must run as root not user cos non-root users can't access these stats
    - user: root
{% endif %}
