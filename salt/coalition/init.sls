{% from 'lib.sls' import create_user %}
  
{% set user = 'coalition' %}
{% set userdir = '/home/' + user %}

include:
  - apache
  - apache.modules.rewrite
  - php-fpm

wp-cli:
  file.managed:
    - name: /usr/local/bin/wp
    - source: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar
    - source_hash: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar.sha512
    - mode: 755

{{ create_user(user) }}

allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/public_html:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists
