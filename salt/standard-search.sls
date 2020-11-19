{% from 'lib.sls' import configurefirewall %}

include:
  - django

elasticsearch:
  pkgrepo.managed:
    - humanname: Elasticsearch
    - name: deb https://artifacts.elastic.co/packages/7.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - key_url: https://packages.elasticsearch.org/GPG-KEY-elasticsearch
  pkg.installed:
    - pkgs:
      - apt-transport-https
      - elasticsearch
      - openjdk-8-jre-headless
  service.running:
    - name: elasticsearch
    - enable: True
    - watch:
      - file: /etc/elasticsearch/*
  # Only listen on localhost.
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        network.host: 127.0.0.1

/etc/default/elasticsearch:
  file.managed:
    - source: salt://standard-search/elasticsearch-defaults
    - template: jinja

/etc/elasticsearch/jvm.options:
  file.managed:
    - source: salt://standard-search/jvm.options
    - template: jinja
