{% from 'lib.sls' import createuser, set_firewall %}
# https://developpaper.com/add-authentication-to-prometheus-node-exporter/

{{ set_firewall("PRIVATE_PROMETHEUS_CLIENT") }}
{{ set_firewall("PROMETHEUS_IPV4", pillar.firewall.prometheus_ipv4) }}
{{ set_firewall("PROMETHEUS_IPV6", pillar.firewall.prometheus_ipv6) }}

{% set user = 'prometheus-client' %}
{{ createuser(user) }}

## Get binary
# Note: This does not clean up old versions.

get_prometheus_client:
  cmd.run:
    - name: curl -L https://github.com/prometheus/node_exporter/releases/download/v{{ pillar.prometheus_node_exporter.version }}/node_exporter-{{ pillar.prometheus_node_exporter.version }}.linux-amd64.tar.gz -o /home/{{ user }}/node_exporter-{{ pillar.prometheus_node_exporter.version }}.tar.gz
    - creates: /home/{{ user }}/node_exporter-{{ pillar.prometheus_node_exporter.version }}.tar.gz
    - require:
      - user: {{ user }}_user_exists

extract_prometheus_client:
  cmd.run:
    - name: tar xvzf node_exporter-{{ pillar.prometheus_node_exporter.version }}.tar.gz
    - creates: /home/{{ user }}/node_exporter-{{ pillar.prometheus_node_exporter.version }}.linux-amd64/node_exporter
    - cwd: /home/{{ user }}/
    - require:
      - cmd: get_prometheus_client

## TLS configuration
# Note: The same self-signed certificate is used on multiple machines. Since it's only for Node Exporter, that's OK.

# The private key and certificate request were created with:
# openssl req -nodes -x509 -days 3650 -out node_exporter.pem -newkey rsa:2048 -keyout node_exporter.key -subj "/CN=*.open-contracting.org"
# To re-generate the certificate request:
# openssl req -nodes -x509 -days 3650 -out node_exporter.pem -new -key node_exporter.key -subj "/CN=*.open-contracting.org"
# https://www.openssl.org/docs/manmaster/man1/openssl-req.html
/home/{{ user }}/node_exporter.key:
  file.managed:
    - source: salt://private/keys/node_exporter.key
    - user: {{ user }}
    - group: {{ user }}
    - mode: 600
    - require:
      - user: {{ user }}_user_exists

/home/{{ user }}/node_exporter.pem:
  file.managed:
    - source: salt://private/keys/node_exporter.pem
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

# https://github.com/prometheus/node_exporter/blob/v1.0.1/https/README.md
/home/{{ user }}/config.yaml:
  file.managed:
    - source: salt://prometheus_node_exporter/files/config.yaml
    - template: jinja
    - context:
        user: {{ user }}
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

## Start service
# https://github.com/prometheus/node_exporter/tree/master/examples/systemd

/etc/systemd/system/prometheus-node-exporter.service:
  file.managed:
    - source: salt://prometheus_node_exporter/files/prometheus-node-exporter.service
    - template: jinja
    - context:
        user: {{ user }}
    - require:
      - user: {{ user }}_user_exists

prometheus-node-exporter:
  service.running:
    - enable: True
    - require:
      - file: /etc/systemd/system/prometheus-node-exporter.service
      - cmd: extract_prometheus_client
    # Make sure service restarts if any config changes
    - watch:
      - file: /home/{{ user }}/node_exporter.key
      - file: /home/{{ user }}/node_exporter.pem
      - file: /home/{{ user }}/config.yaml
      - file: /etc/systemd/system/prometheus-node-exporter.service

## Smartmontools

{% if salt['pillar.get']('prometheus_node_exporter:smartmon') %}
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
