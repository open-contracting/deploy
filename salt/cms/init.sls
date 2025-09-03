{% from 'lib.sls' import create_user %}

include:
  - apache.modules.rewrite # required by WordPress
  - php-fpm

wp-cli:
  file.managed:
    - name: /usr/local/bin/wp
    - source: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar
    - source_hash: https://github.com/wp-cli/wp-cli/releases/download/v{{ pillar.wordpress.cli_version }}/wp-cli-{{ pillar.wordpress.cli_version }}.phar.sha512
    - mode: 755


{% for name, entry in pillar.phpfpm.sites|items %}
{% set user = entry.context.user %}
{% set userdir = '/home/' + user %}

{{ create_user(user, authorized_keys=pillar.ssh.get(user, [])) }}

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

{{ name }} wp cron:
  cron.present:
    - name: /usr/local/bin/wp cron event run --due-now
    - user: {{ user }}
    - identifier: WORDPRESS_SITE_CRON
    - minute: '*/5'
    - require:
      - user: {{ user }}_user_exists
{% endfor %}
