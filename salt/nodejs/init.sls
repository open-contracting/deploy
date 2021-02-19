{% set node_version = pillar.nodejs.get('version', '14') %}

nodejs:
  pkgrepo.managed:
    - humanname: Nodejs Official Repository
    - name: deb https://deb.nodesource.com/node_{{node_version}}.x {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
  pkg.installed:
    - require:
      - pkgrepo: nodejs