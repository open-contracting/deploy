{% from 'lib.sls' import createuser,  apache %}

include:
  - apache
  - apache-proxy

prometheus-alertmanager-deps:
    pkg.installed:
      - pkgs:
        - curl

{% set user = 'prometheus-alertmanager' %}
{{ createuser(user) }}

## Get binary

get_prometheus_alertmanager:
  cmd.run:
    - name: curl -L https://github.com/prometheus/alertmanager/releases/download/v{{ pillar.prometheus.server_alertmanager_version }}/alertmanager-{{ pillar.prometheus.server_alertmanager_version }}.linux-amd64.tar.gz -o /home/{{ user }}/alertmanager-{{ pillar.prometheus.server_alertmanager_version }}.tar.gz
    - creates: /home/{{ user }}/alertmanager-{{ pillar.prometheus.server_alertmanager_version }}.tar.gz
    - requires:
      - pkg.prometheus-alertmanager-deps
      - user: {{ user }}_user_exists

extract_prometheus_alertmanager:
  cmd.run:
    - name: tar xvzf alertmanager-{{ pillar.prometheus.server_alertmanager_version }}.tar.gz
    - creates: /home/{{ user }}/alertmanager-{{ pillar.prometheus.server_alertmanager_version }}.linux-amd64/alertmanager
    - cwd: /home/{{ user }}/
    - requires:
      - cmd.get_prometheus_alertmanager

## Configure

/home/{{ user }}/conf-alertmanager.yml:
  file.managed:
    - source: salt://private/prometheus-server-alertmanager/conf-alertmanager.yml
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

/etc/systemd/system/prometheus-alertmanager.service:
  file.managed:
    - source: salt://prometheus-server-alertmanager/prometheus-alertmanager.service
    - template: jinja
    - context:
        user: {{ user }}
    - requires:
      - user: {{ user }}_user_exists

prometheus-alertmanager:
  service.running:
    - enable: True
    - requires:
      - cmd: extract_prometheus_alertmanager
    # Make sure service restarts if any config changes
    - watch:
      - file: /home/{{ user }}/conf-alertmanager.yml
      - file: /etc/systemd/system/prometheus-alertmanager.service

## Apache reverse proxy with password for security

{{ apache('prometheus-alertmanager',
    servername=pillar.prometheus.alertmanager_fqdn,
    https=pillar.prometheus.alertmanager_https,
    extracontext='user: ' + user) }}

prometheus-alertmanager-apache-password:
  cmd.run:
    - name: htpasswd -b -c /home/{{ user }}/htpasswd prom {{ pillar.prometheus.alertmanager_password }}
    - runas: {{ user }}
    - cwd: /home/{{ user }}
