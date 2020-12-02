{% from 'lib.sls' import createuser, apache %}

include:
  - apache.public
  - apache.modules.proxy_http

{% set user = 'prometheus-server' %}
{% set userdir = '/home/' + user %}
{{ createuser(user) }}

## Get binary

get_prometheus:
  cmd.run:
    - name: curl -L https://github.com/prometheus/prometheus/releases/download/v{{ pillar.prometheus_server.version }}/prometheus-{{ pillar.prometheus_server.version }}.linux-amd64.tar.gz -o /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - creates: /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - require:
      - user: {{ user }}_user_exists

extract_prometheus:
  cmd.run:
    - name: tar xvzf prometheus-{{ pillar.prometheus_server.version }}.tar.gz
    - creates: /home/{{ user }}/prometheus-{{ pillar.prometheus_server.version }}.linux-amd64/prometheus
    - cwd: /home/{{ user }}/
    - require:
      - cmd: get_prometheus

## Configure

/home/{{ user }}/conf-prometheus.yml:
  file.managed:
    - source: salt://private/prometheus-server-monitor/conf-prometheus.yml
    - template: jinja
    - context:
        user: {{ user }}
    - require:
      - user: {{ user }}_user_exists

/home/{{ user }}/conf-prometheus-rules.yml:
  file.managed:
    - source: salt://private/prometheus-server-monitor/conf-prometheus-rules.yml
    - template: jinja
    - context:
        user: {{ user }}
    - require:
      - user: {{ user }}_user_exists

## Data

/home/{{ user }}/data:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists

## Start service

/etc/systemd/system/prometheus-server.service:
  file.managed:
    - source: salt://prometheus-server-monitor/prometheus-server.service
    - template: jinja
    - context:
        user: {{ user }}
    - require:
      - user: {{ user }}_user_exists

prometheus-server:
  service.running:
    - enable: True
    - reload: True
    - require:
      - cmd: extract_prometheus
      - file: /home/{{ user }}/data
    # Make sure service restarts if any config changes
    - watch:
      - file: /home/{{ user }}/conf-prometheus.yml
      - file: /home/{{ user }}/conf-prometheus-rules.yml
      - file: /etc/systemd/system/prometheus-server.service

{{ apache('prometheus-server',
    servername=pillar.prometheus_server.fqdn,
    https=pillar.prometheus_server.https,
    extracontext='user: ' + user) }}
