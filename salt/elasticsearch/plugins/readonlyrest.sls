# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md

include:
  - elasticsearch

{% set readonlyrest_version = '1.43.0_es7.17.6' %}

readonlyrest-download:
  file.managed:
    - name: /opt/readonlyrest-{{ readonlyrest_version }}.zip
    - source: salt://private/files/readonlyrest-{{ readonlyrest_version }}.zip

readonlyrest-install:
  cmd.run:
    - name: "yes | /usr/share/elasticsearch/bin/elasticsearch-plugin install --silent file:///opt/readonlyrest-{{ readonlyrest_version }}.zip"
    - require:
      - pkg: elasticsearch
    - onchanges:
      - file: readonlyrest-download
    - watch_in:
      - service: elasticsearch

/opt/pkcs-password:
  file.managed:
    - name: /opt/pkcs-password
    - contents_pillar: elasticsearch:plugins:readonlyrest:key_pass
    - mode: 600

/opt/pem-to-keystore.sh:
  pkg.installed:
    - name: openjdk-11-jre-headless # for keytool command
  file.managed:
    - name: /opt/pem-to-keystore.sh
    - source: salt://elasticsearch/files/pem-to-keystore.sh
    - mode: 700
    - require:
      - pkg: apache2
      - pkg: elasticsearch
      - pkg: /opt/pem-to-keystore.sh
      - file: /opt/pkcs-password

/opt/pem-to-keystore-wrapper.sh:
  file.managed:
    - name: /opt/pem-to-keystore-wrapper.sh
    - source: salt://elasticsearch/files/pem-to-keystore-wrapper.sh
    - user: root
    - group: root
    - mode: 755
    - require:
      - file: /opt/pem-to-keystore.sh

/etc/sudoers.d/90-pem-to-keystore:
  file.managed:
    - source: salt://elasticsearch/files/sudoers.d/pem-to-keystore
    - user: root
    - group: root
    - mode: 440
    # Salt appends to check_cmd a temporary file containing the new managed contents. This serves as the argument to `-f`.
    - check_cmd: visudo -c -f
    - require:
      - file: /opt/pem-to-keystore.sh

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
