# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md

include:
  - elasticsearch

# Follow these instructions for upgrading:
# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#upgrading-the-plugin
{% set readonlyrest_version = '1.25.2_es7.10.1' %}

readonlyrest-download:
  file.managed:
    - name: /opt/readonlyrest-{{ readonlyrest_version }}.zip
    - source: https://{{ pillar.github.access_token }}:x-oauth-basic@raw.githubusercontent.com/open-contracting/deploy-salt-private/master/files/readonlyrest-{{ readonlyrest_version }}.zip
    - source_hash: eeef2aeafdf023b355c66d528763a2e1886ea465

# The plugin requires user input (it provides no `--yes` option).
readonlyrest-installer:
  pkg.installed:
    - name: expect
  file.managed:
    - name: /opt/readonlyrest-installer.sh
    - source: salt://elasticsearch/files/readonlyrest-installer.sh
    - template: jinja
    - context:
        version: {{ readonlyrest_version }}
    - mode: 755
    - require:
      - pkg: readonlyrest-installer

readonlyrest-install:
  cmd.run:
    - name: /opt/readonlyrest-installer.sh
    - require:
      - pkg: elasticsearch
    - onchanges:
      - file: readonlyrest-download
      - file: readonlyrest-installer
    - watch_in:
      - service: elasticsearch

pkcs-password:
  file.managed:
    - name: /opt/pkcs-password
    - contents_pillar: elasticsearch:plugins:readonlyrest:key_pass
    - mode: 600

pem-to-keystore.sh:
  pkg.installed:
    - name: openjdk-11-jre-headless # for keytool command
  file.managed:
    - name: /opt/pem-to-keystore.sh
    - source: salt://elasticsearch/files/pem-to-keystore.sh
    - mode: 700
    - require:
      - pkg: apache2
      - pkg: elasticsearch
      - pkg: pem-to-keystore.sh
      - file: pkcs-password

readonlyrest.yml:
  file.managed:
    - name: /etc/elasticsearch/readonlyrest.yml
    - source: salt://elasticsearch/files/config/readonlyrest-{{ pillar.elasticsearch.plugins.readonlyrest.configuration }}.yml
    - template: jinja
    - require:
      - pkg: elasticsearch
    - watch_in:
      - service: elasticsearch

elasticsearch.yml:
  file.append:
    - name: /etc/elasticsearch/elasticsearch.yml
    - text:
      # https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#4-disable-x-pack-security-module
      - "xpack.security.enabled: false"
      # https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#external-rest-api
      - "http.type: ssl_netty4"
    - require:
      - pkg: elasticsearch
    - watch_in:
      - service: elasticsearch
