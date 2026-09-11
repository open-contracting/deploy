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

/usr/local/lib/wp-cli/check-updates.php:
  file.managed:
    - source: salt://cms/files/check-updates.php
    - makedirs: True

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

{% for user, entry in pillar.wordpress.sites|items %}
{% set userdir = '/home/' + user %}
{% set database = pillar.mysql.databases[entry.database] %}

{% for constant, value in (
    ('DB_NAME', entry.database),
    ('DB_USER', database.user),
    ('DB_PASSWORD', pillar.mysql.users[database.user].password),
) %}
/home/{{ user }}/public_html/wp-config.php {{ constant }}:
  file.replace:
    - name: /home/{{ user }}/public_html/wp-config.php
    - pattern: "(define\\(\\s*'{{ constant }}',\\s*')[^']*(')"
    - repl: "\\g<1>{{ value }}\\g<2>"
    - backup: False
    - ignore_if_missing: True
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

{% for name in entry.plugins|default([]) %}
/home/{{ user }}/public_html/wp-content/mu-plugins/opencontracting-{{ name }}.php:
  file.managed:
    - source: salt://cms/files/{{ name }}.php
    - template: jinja
    - context: {{ entry.context|yaml }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

{% set checks = entry.checks|default({}) %}
{% if checks.get('enabled') %}
{% set wp = '/usr/local/bin/wp --no-color --path=' ~ userdir ~ '/public_html' %}
# The must-use plugins above have no checksums at wordpress.org.
{% set exclude = checks.premium_plugins|default([]) + entry.plugins|default([])|map('regex_replace', '^', 'opencontracting-')|list %}

# Not --quiet, which also hides the warnings that name the files.
WordPress integrity check for {{ user }}:
  cron.present:
    - name: '( {{ wp }} core verify-checksums; {{ wp }} plugin verify-checksums --all --exclude={{ exclude|join(',') }} ) 2>&1 | grep -v "^Success: "'
    - identifier: WORDPRESS_INTEGRITY_CHECK
    - user: {{ user }}
    - hour: 5
    - minute: 30
    - require:
      - user: {{ user }}_user_exists
      - file: wp-cli

WordPress updates check for {{ user }}:
  cron.present:
    - name: {{ wp }} eval-file /usr/local/lib/wp-cli/check-updates.php
    - identifier: WORDPRESS_UPDATES_CHECK
    - user: {{ user }}
    - hour: 5
    - minute: 45
    - require:
      - user: {{ user }}_user_exists
      - file: wp-cli
      - file: /usr/local/lib/wp-cli/check-updates.php
{% endif %}
{% endfor %}
