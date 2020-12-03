{% from 'lib.sls' import createuser %}

# Note user variable is set in other prometheus_node_exporter State file, too!
{% set user = 'prometheus-client' %}
{{ createuser(user) }}

## Get binary

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

## Start service

/etc/systemd/system/prometheus-node-exporter.service:
  file.managed:
    - source: salt://prometheus-client/prometheus-node-exporter.service
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
      - file: /etc/systemd/system/prometheus-node-exporter.service

## Smartmontools

{% if pillar.prometheus_node_exporter.smartmon %}
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
