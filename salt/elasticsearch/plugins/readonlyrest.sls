# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md

include:
  - elasticsearch

# ror-tools.jar patch required on ES version 8.0+ https://docs.readonlyrest.com/elasticsearch#3.-patch-elasticsearch
readonlyrest-install:
  cmd.run:
    - name: "yes | /usr/share/elasticsearch/bin/elasticsearch-plugin install -b \"https://api.beshu.tech/download/es?esVersion={{ pillar.elasticsearch.version }}\";
            /usr/share/elasticsearch/jdk/bin/java -jar /usr/share/elasticsearch/plugins/readonlyrest/ror-tools.jar patch"
    - require:
      - pkg: elasticsearch
    - creates: "/usr/share/elasticsearch/plugins/readonlyrest/readonlyrest-{{ pillar.elasticsearch.plugins.readonlyrest.version }}.jar"
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/readonlyrest.yml:
  file.managed:
    - name: /etc/elasticsearch/readonlyrest.yml
    - source: salt://elasticsearch/files/config/readonlyrest-{{ pillar.elasticsearch.plugins.readonlyrest.configuration }}.yml
    - template: jinja
    - require:
      - pkg: elasticsearch
    - watch_in:
      - service: elasticsearch

/etc/elasticsearch/elasticsearch.yml for readonlyrest:
  file.keyvalue:
    - name: /etc/elasticsearch/elasticsearch.yml
    - key_values:
        # https://github.com/beshu-tech/readonlyrest-docs/blob/master/kibana.md#malformed-in-index-settings
        readonlyrest.force_load_from_file: 'true'
        # https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#5-disable-x-pack-security-module
        xpack.security.enabled: 'false'
    - separator: ': '
    - append_if_not_found: True
    - require:
      - pkg: elasticsearch
    - watch_in:
      - service: elasticsearch
