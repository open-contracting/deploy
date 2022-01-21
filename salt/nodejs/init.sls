{% set node_version = pillar.nodejs.get('version', '16') %}

# https://github.com/nodesource/distributions
nodejs:
  pkgrepo.managed:
    - humanname: Node.js Official Repository
    - name: deb https://deb.nodesource.com/node_{{node_version}}.x {{ grains.oscodename }} main
    - file: /etc/apt/sources.list.d/nodesource.list
    - key_url: https://deb.nodesource.com/gpgkey/nodesource.gpg.key
  pkg.installed:
    - name: nodejs
    - require:
      - pkgrepo: nodejs
