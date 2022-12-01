# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md

include:
  - elasticsearch

readonlyrest-install:
  cmd.run:
    - name: "yes | /usr/share/elasticsearch/bin/elasticsearch-plugin install -b \"https://api.beshu.tech/download/es?esVersion={{ pillar.elasticsearch.version }}\""
    - require:
      - pkg: elasticsearch
    - creates: "/usr/share/elasticsearch/plugins/readonlyrest/readonlyrest-{{ pillar.elasticsearch.plugins.readonlyrest.version }}.jar"
    - watch_in:
      - service: elasticsearch

/opt/restart-elasticsearch.sh:
  file.managed:
    - name: /opt/restart-elasticsearch.sh
    - source: salt://elasticsearch/files/restart-elasticsearch.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - pkg: apache2
      - pkg: elasticsearch

/etc/sudoers.d/90-restart-elasticsearch:
  file.managed:
    - source: salt://elasticsearch/files/sudoers.d/restart-elasticsearch
    - user: root
    - group: root
    - mode: 440
    # Salt appends to check_cmd a temporary file containing the new managed contents. This serves as the argument to `-f`.
    - check_cmd: visudo -c -f
    - require:
      - file: /opt/restart-elasticsearch.sh

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
        # https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#4-disable-x-pack-security-module
        xpack.security.enabled: 'false'
        # https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#external-rest-api
        http.type: ssl_netty4
    - separator: ': '
    - append_if_not_found: True
    - require:
      - pkg: elasticsearch
    - watch_in:
      - service: elasticsearch
