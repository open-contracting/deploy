{% from 'lib.sls' import create_user, set_cron_env %}

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

{{ set_cron_env(user, 'MAILTO', entry.cron.contact|join(','), 'cms' ) }}

# Assumes that all PHP-FPM sites on the CMS server are WordPress.

/usr/local/bin/wp cron event run --quiet --due-now --path={{ userdir }}/public_html{% if 'ignore' in entry.cron %} 2>&1 | grep -v '{{ entry.cron.ignore|join('\|') }}'{% endif %}:
  cron.present:
    - identifier: WORDPRESS_SITE_CRON
    - user: {{ user }}
    - minute: '*/5'
    - require:
      - user: {{ user }}_user_exists
{% endfor %}
