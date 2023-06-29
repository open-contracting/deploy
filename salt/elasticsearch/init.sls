elasticsearch:
  pkgrepo.managed:
    - humanname: Elasticsearch Official Repository
    - name: deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main
    - file: /etc/apt/sources.list.d/elasticsearch.list
    - key_url: https://packages.elasticsearch.org/GPG-KEY-elasticsearch
    - aptkey: False
  pkg.installed:
    - name: elasticsearch
    - require:
      - pkgrepo: elasticsearch
  service.running:
    - name: elasticsearch
    - enable: True
    - require:
      - pkg: elasticsearch

# https://www.elastic.co/guide/en/elasticsearch/reference/8.8/important-settings.html#heap-size-settings
# https://www.elastic.co/guide/en/elasticsearch/reference/8.8/advanced-configuration.html#set-jvm-heap-size
set jvm heap size:
  file.managed:
    - name: /etc/elasticsearch/jvm.options.d/memory.options
    - group: elasticsearch
    - contents: |
       -Xms{{ grains.mem_total // 5 * 2 }}m
       -Xmx{{ grains.mem_total // 5 * 2 }}m
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/elasticsearch.yml:
  file.keyvalue:
    - name: /etc/elasticsearch/elasticsearch.yml
    - key_values:
        # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-network.html
        http.host: 127.0.0.1
        network.bind_host: 127.0.0.1
        network.publish_host: _local_
        # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/query-dsl.html
        search.allow_expensive_queries: 'false'
        # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-scripting-security.html
        script.allowed_types: inline
        script.allowed_contexts: ingest
        # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/bootstrap-checks.html
        discovery.type: single-node
    - separator: ': '
    - append_if_not_found: True
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/elasticsearch.yml disable cluster mode:
  file.comment:
    - name: /etc/elasticsearch/elasticsearch.yml
    - regex: "^cluster.initial_master_nodes:"
    - backup: False
    - ignore_missing: True

{# Prevent ElasticSearch from starting in the case of misconfiguration. #}
/etc/elasticsearch/jvm.options.d/bootstrap-checks.options:
  file.managed:
    - name: /etc/elasticsearch/jvm.options.d/bootstrap-checks.options
    - contents: "-Des.enforce.bootstrap.checks=true"
    - watch_in:
      - service: elasticsearch
