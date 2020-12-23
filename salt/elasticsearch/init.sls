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

# https://www.elastic.co/guide/en/elasticsearch/reference/7.10/important-settings.html#heap-size-settings
# https://www.elastic.co/guide/en/elasticsearch/reference/7.10/jvm-options.html
set JVM minimum heap size:
  file.replace:
    - name: /etc/elasticsearch/jvm.options
    - pattern: ^-Xms.+
    - repl: -Xms{{ grains.mem_total // 2 }}m
    - watch_in:
      - service: elasticsearch

set JVM maximum heap size:
  file.replace:
    - name: /etc/elasticsearch/jvm.options
    - pattern: ^-Xmx.+
    - repl: -Xmx{{ grains.mem_total // 2 }}m
    - watch_in:
      - service: elasticsearch

{% if pillar.elasticsearch.get('public_access') %}
/etc/elasticsearch/elasticsearch.yml:
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text:
      # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-network.html
      - "network.bind_host: 0.0.0.0"
      - "network.publish_host: _local_"
      # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/query-dsl.html
      - "search.allow_expensive_queries: false"
      # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-scripting-security.html
      - "script.allowed_types: none"
      - "script.allowed_contexts: none"
      # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/bootstrap-checks.html
      - "discovery.type: single-node"
      # https://www.elastic.co/guide/en/elasticsearch/reference/7.10/modules-http.html
      {% if 'allowed_origins' in pillar.elasticsearch %}
      - "http.cors.enabled: true"
      - "http.cors.allow-origin: {{ pillar.elasticsearch.allowed_origins }}"
      - "http.cors.allow-methods: OPTIONS, GET"
      {% endif %}
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/jvm.options.d/bootstrap-checks:
  file.managed:
    - name: /etc/elasticsearch/jvm.options.d/bootstrap-checks
    - contents: "-Des.enforce.bootstrap.checks=true"
    - watch_in:
      - service: elasticsearch
{% else %}
/etc/elasticsearch/elasticsearch.yml:
  file.comment:
    - name: /etc/elasticsearch/elasticsearch.yml
    - regex: ^network\.bind_host: 0\.0\.0\.0$
    - backup: False
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/jvm.options.d/bootstrap-checks:
  file.absent:
    - name: /etc/elasticsearch/jvm.options.d/bootstrap-checks
    - watch_in:
      - service: elasticsearch
{% endif %}
