{% from 'lib.sls' import set_firewall %}

include:
  - prometheus

{% set user = pillar.prometheus.node_exporter.user %}
{% set userdir = '/home/' + user %}

{{ set_firewall('PRIVATE_PROMETHEUS_CLIENT') }}
{{ set_firewall('PROMETHEUS_IPV4', pillar.firewall.prometheus_ipv4) }}
{{ set_firewall('PROMETHEUS_IPV6', pillar.firewall.prometheus_ipv6) }}

# The same self-signed certificate is used on multiple machines. Since it's only for Node Exporter, that's OK.
#
# https://developpaper.com/add-authentication-to-prometheus-node-exporter/
{{ userdir }}/node_exporter.key:
  file.managed:
    - contents_pillar: prometheus:node_exporter:ssl:privkey
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - require:
      - user: {{ user }}_user_exists
    - watch_in:
      - module: prometheus-node-exporter-reload

## Smartmontools

{% if pillar.prometheus.node_exporter.get('smartmon') %}
smartmontools:
  pkg.installed:
    - name: smartmontools

{{ userdir }}/node-exporter-textfile-directory:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

/opt/node-exporter-textfile-collector-scripts:
  git.latest:
    - name: https://github.com/prometheus-community/node-exporter-textfile-collector-scripts
    - user: root
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: /opt/node-exporter-textfile-collector-scripts
    - require:
      - pkg: git

# This must be run as the root user, because non-root users can't access these statistics.
/opt/node-exporter-textfile-collector-scripts/smartmon.sh > {{ userdir }}/node-exporter-textfile-directory/smartmon.sh.prom:
  cron.present:
    - identifier: PROMETHEUS_CLIENT_TEXTFILE_COLLECTOR_SMARTMON
    - user: root
    - require:
      - git: /opt/node-exporter-textfile-collector-scripts
      - file: {{ userdir }}/node-exporter-textfile-directory
{% endif %}
