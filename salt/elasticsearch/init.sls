{% from 'lib.sls' import set_firewall %}

{{ set_firewall("PUBLIC_ELASTICSEARCH") }}

elasticsearch:
  pkgrepo.managed:
    - humanname: Elasticsearch Official Repository
    - name: deb https://artifacts.elastic.co/packages/7.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - key_url: https://packages.elasticsearch.org/GPG-KEY-elasticsearch
  pkg.installed:
    - name: elasticsearch
  service.running:
    - enable: True

# If we run Elasticsearch on a server with less than (or more than) 2GB RAM, we need to configure Xms and Xmx in
# /etc/elasticsearch/jvm.options.
#
# https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#heap-size-settings
# https://www.elastic.co/guide/en/elasticsearch/reference/current/jvm-options.html
