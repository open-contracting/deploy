{% from 'lib.sls' import aws_site_backup, create_user %}

{% set user = 'coalition' %}
{% set userdir = '/home/' + user %}

include:
  - apache.modules.rewrite # required by WordPress
  - aws
  - php-fpm

wp-cli:
  file.managed:
    - name: /usr/local/bin/wp
    - source: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar
    - source_hash: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar.sha512
    - mode: 755

{{ create_user(user) }}

# Allow Apache to access. See wordpress.conf.include.
allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
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

{% if 'backup' in pillar.wordpress %}
{{ aws_site_backup(pillar.wordpress.backup.location, [userdir + '/public_html/']) }}
{% endif %}
