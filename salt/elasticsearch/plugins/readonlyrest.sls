# https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md

include:
  - elasticsearch

{% set readonlyrest_version = '1.25.2_es7.10.1' %}

readonlyrest-download:
  file.managed:
    - name: /root/readonlyrest-{{ readonlyrest_version }}.zip
    - source: https://{{ pillar.github.access_token }}:x-oauth-basic@raw.githubusercontent.com/open-contracting/deploy-salt-private/master/files/readonlyrest-{{ readonlyrest_version }}.zip
    - source_hash: eeef2aeafdf023b355c66d528763a2e1886ea465

# The plugin requires user input (it provides no `--yes` option).
readonlyrest-installer:
  pkg.installed:
    - name: expect
  file.managed:
    - name: /root/readonlyrest-installer.sh
    - source: salt://elasticsearch/files/readonlyrest-installer.sh
    - template: jinja
    - context:
        version: {{ readonlyrest_version }}
    - mode: 755
    - require:
      - pkg: readonlyrest-installer

readonlyrest-install:
  cmd.run:
    - name: /root/readonlyrest-installer.sh
    - require:
      - pkg: elasticsearch
    - onchanges:
      - file: readonlyrest-download
      - file: readonlyrest-installer
