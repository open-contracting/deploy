{% from 'lib.sls' import createuser, apache %}

include:
  - apache
  - apache-proxy

prometheus-server-deps:
    pkg.installed:
      - pkgs:
        - curl

{% set user = 'prometheus-server' %}
{{ createuser(user) }}

## Get binary

get_prometheus:
  cmd.run:
    - name: curl -L https://github.com/prometheus/prometheus/releases/download/v{{ pillar.prometheus_server.version }}/prometheus-{{ pillar.prometheus_server.version }}.linux-amd64.tar.gz -o /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - creates: /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - requires:
      - pkg.prometheus-server-deps
      - user: {{ user }}_user_exists

extract_prometheus:
  cmd.run:
    - name: tar xvzf prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - creates: /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.linux-amd64/prometheus
    - cwd: /home/{{ user }}/
    - requires:
      - cmd.get_prometheus

## Configure

/home/{{ user }}/conf-prometheus.yml:
  file.managed:
    - source: salt://private/prometheus-server-monitor/conf-prometheus.yml
    - template: jinja
    - context:
        user: {{ user }}
    - requires:
      - user: {{ user }}_user_exists

/home/{{ user }}/conf-prometheus-rules.yml:
  file.managed:
    - source: salt://private/prometheus-server-monitor/conf-prometheus-rules.yml
    - template: jinja
    - context:
        user: {{ user }}
    - requires:
      - user: {{ user }}_user_exists

## Data

/home/{{ user }}/data:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - requires:
      - user: {{ user }}_user_exists

## Start service

/etc/systemd/system/prometheus-server.service:
  file.managed:
    - source: salt://prometheus-server-monitor/prometheus-server.service
    - template: jinja
    - context:
        user: {{ user }}
    - requires:
      - user: {{ user }}_user_exists

prometheus-server:
  service.running:
    - enable: True
    - reload: True
    - requires:
      - cmd: extract_prometheus
      - file: /home/{{ user }}/data
    # Make sure service restarts if any config changes
    - watch:
      - file: /home/{{ user }}/conf-prometheus.yml
      - file: /home/{{ user }}/conf-prometheus-rules.yml
      - file: /etc/systemd/system/prometheus-server.service

## Apache reverse proxy with password for security

{{ user }}-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus_server.password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}

{{ apache('prometheus-server',
    servername=pillar.prometheus_server.fqdn,
    https=pillar.prometheus_server.https,
    extracontext='user: ' + user) }}
