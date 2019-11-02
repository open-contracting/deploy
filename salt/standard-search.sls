include:
  - django

elasticsearch:
  cmd.run:
    - name: wget -nv -O - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
  pkgrepo.managed:
    - humanname: Elasticsearch
    - name: deb https://artifacts.elastic.co/packages/6.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
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
  # Ensure elasticsearch only listens on localhost, doesn't multicast
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text: |
        network.host: 127.0.0.1

/etc/default/elasticsearch:
  file.managed:
    - source: salt://etc-default/elasticsearch-standard-search
    - template: jinja

/etc/elasticsearch/jvm.options:
  file.managed:
    - source: salt://standard-search/jvm.options
    - template: jinja
