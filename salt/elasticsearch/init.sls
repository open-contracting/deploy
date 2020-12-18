{% from 'lib.sls' import set_firewall %}

{% if pillar.elasticsearch.get('public_access') %}
  {{ set_firewall("PUBLIC_ELASTICSEARCH") }}
{% else %}
  {{ unset_firewall("PUBLIC_ELASTICSEARCH") }}
{% endif %}

elasticsearch:
  pkgrepo.managed:
    - humanname: Elasticsearch Official Repository
    - name: deb https://artifacts.elastic.co/packages/7.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - key_url: https://packages.elasticsearch.org/GPG-KEY-elasticsearch
  pkg.installed:
    - name: elasticsearch
    - require:
      - pkgrepo: elasticsearch
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: elasticsearch

# If we run Elasticsearch on a server with less than (or more than) 2GB RAM, we need to configure Xms and Xmx in
# /etc/elasticsearch/jvm.options.
#
# https://www.elastic.co/guide/en/elasticsearch/reference/7.10/important-settings.html#heap-size-settings
# https://www.elastic.co/guide/en/elasticsearch/reference/7.10/jvm-options.html
