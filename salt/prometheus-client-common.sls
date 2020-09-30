{% from 'lib.sls' import createuser %}

prometheus-client-deps:
  pkg.installed:
    - name: curl

# Note user variable is set in other prometheus-client-*.sls files too!
{% set user = 'prometheus-client' %}
{{ createuser(user) }}

########### Get binary

get_prometheus_client:
  cmd.run:
    - name: curl -L https://github.com/prometheus/node_exporter/releases/download/v{{ pillar.prometheus.node_exporter_version }}/node_exporter-{{ pillar.prometheus.node_exporter_version }}.linux-amd64.tar.gz -o /home/{{ user }}/node_exporter-{{ pillar.prometheus.node_exporter_version }}.tar.gz
    - creates: /home/{{ user }}/node_exporter-{{ pillar.prometheus.node_exporter_version }}.tar.gz
    - requires:
      - pkg.prometheus-client-deps
      - user: {{ user }}_user_exists

extract_prometheus_client:
  cmd.run:
    - name: tar xvzf node_exporter-{{ pillar.prometheus.node_exporter_version }}.tar.gz
    - creates: /home/{{ user }}/node_exporter-{{ pillar.prometheus.node_exporter_version }}.linux-amd64/node_exporter
    - cwd: /home/{{ user }}/
    - requires:
      - cmd.get_prometheus

########### Service

/etc/systemd/system/prometheus-node-exporter.service:
  file.managed:
    - source: salt://prometheus-client/prometheus-node-exporter.service
    - template: jinja
    - context:
        user: {{ user }}
    - requires:
      - user: {{ user }}_user_exists

prometheus-node-exporter:
  service.running:
    - enable: True
    - requires:
      - file: /etc/systemd/system/prometheus-node-exporter.service
      - cmd: extract_prometheus_client
    # Make sure service restarts if any config changes
    - watch:
      - file: /etc/systemd/system/prometheus-node-exporter.service


########### General Textfile Collector

{% if pillar.prometheus.client_node_exporter_textfile_collector_smartmon %}
/home/{{ user }}/node-exporter-textfile-directory:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - requires:
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

{% endif %}


########### SmartMon?

{% if pillar.prometheus.client_node_exporter_textfile_collector_smartmon %}

smartmontools:
  pkg.installed:
    - name: smartmontools

/home/prometheus-client/node-exporter-textfile-collector-scripts/smartmon.sh > /home/{{ user }}/node-exporter-textfile-directory/smartmon.sh.prom:
  cron.present:
    - identifier: PROMETHEUS_CLIENT_TEXTFILE_COLLECTOR_SMARTMON
    # This must run as root not user cos non-root users can't access these stats
    - user: root

{% endif %}
