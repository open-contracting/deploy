{% from 'lib.sls' import apache, createuser %}

include:
  - apache.public
  - apache.modules.proxy_http

{% set user = 'prometheus-alertmanager' %}
{% set userdir = '/home/' + user %}
{{ createuser(user) }}

## Get binary

get_prometheus_alertmanager:
  cmd.run:
    - name: curl -L https://github.com/prometheus/alertmanager/releases/download/v{{ pillar.prometheus_alertmanager.version }}/alertmanager-{{ pillar.prometheus_alertmanager.version }}.linux-amd64.tar.gz -o /home/{{ user }}/alertmanager-{{ pillar.prometheus_alertmanager.version }}.tar.gz
    - creates: /home/{{ user }}/alertmanager-{{ pillar.prometheus_alertmanager.version }}.tar.gz
    - require:
      - user: {{ user }}_user_exists

extract_prometheus_alertmanager:
  cmd.run:
    - name: tar xvzf alertmanager-{{ pillar.prometheus_alertmanager.version }}.tar.gz
    - creates: /home/{{ user }}/alertmanager-{{ pillar.prometheus_alertmanager.version }}.linux-amd64/alertmanager
    - cwd: /home/{{ user }}/
    - require:
      - cmd: get_prometheus_alertmanager

## Configure

/home/{{ user }}/conf-alertmanager.yml:
  file.managed:
    - source: salt://prometheus/files/alertmanager/conf-alertmanager.yml
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

/etc/systemd/system/prometheus-alertmanager.service:
  file.managed:
    - source: salt://prometheus/files/alertmanager/prometheus-alertmanager.service
    - template: jinja
    - context:
        user: {{ user }}
    - require:
      - user: {{ user }}_user_exists

prometheus-alertmanager:
  service.running:
    - enable: True
    - restart: True
    - require:
      - cmd: extract_prometheus_alertmanager
      - file: /home/{{ user }}/data
    # Make sure service restarts if any config changes
    - watch:
      - file: /home/{{ user }}/conf-alertmanager.yml
      - file: /etc/systemd/system/prometheus-alertmanager.service

{{ apache('prometheus-alertmanager',
    servername=pillar.prometheus_alertmanager.fqdn,
    https=pillar.prometheus_alertmanager.https,
    extracontext='user: ' + user) }}
