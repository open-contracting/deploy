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

{% for user, entry in pillar.wordpress.sites|items %}
{% set userdir = '/home/' + user %}
{% set database = pillar.mysql.databases[entry.database] %}
{% set mu_plugins = salt['pillar.get']('wordpress:mu_plugins', []) + entry.mu_plugins|default([]) %}

# Every PHP-FPM site on this server is a WordPress site, so the pool users are created here.
{{ create_user(user, authorized_keys=pillar.ssh.get(user, [])) }}

# Allow Apache to traverse to, and read, what it serves. See wordpress.conf.include. Parents first.
set {{ userdir }} directory permissions:
  file.directory:
    - names:
      - {{ userdir }}
      - {{ userdir }}/public_html
      - {{ userdir }}/public_html/wp-content
      - {{ userdir }}/public_html/wp-content/uploads
      - {{ userdir }}/public_html/wp-content/plugins
      - {{ userdir }}/public_html/wp-content/themes
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

set {{ userdir }}/public_html file permissions:
  file.managed:
    - names:
      - {{ userdir }}/public_html/wp-config.php:
        - mode: 600
      - {{ userdir }}/public_html/.htaccess:
        - mode: 644
    - replace: False
    - create: False
    - require:
      - file: {{ userdir }}/public_html

{{ set_cron_env(user, 'MAILTO', entry.cron.contact|join(','), 'cms' ) }}

/usr/local/bin/wp cron event run --quiet --due-now --path={{ userdir }}/public_html{% if 'ignore' in entry.cron %} 2>&1 | grep -v '{{ entry.cron.ignore|join('\|') }}'{% endif %}:
  cron.present:
    - identifier: WORDPRESS_SITE_CRON
    - user: {{ user }}
    - minute: '*/5'
    - require:
      - user: {{ user }}_user_exists

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

# Values are strings of PHP source. `wp config get` prints the evaluated value, like `php -r 'echo …;'`.
{% for constant, value in dict(salt['pillar.get']('wordpress:constants', {}), **entry.constants|default({}))|items %}
set {{ constant }} in {{ user }} wp-config.php:
  cmd.run:
    - name: /usr/local/bin/wp config set {{ constant }} "{{ value }}" --raw
    - runas: {{ user }}
    - cwd: {{ userdir }}/public_html
    - onlyif: test -f {{ userdir }}/public_html/wp-config.php
    - unless: >-
        value=$(/usr/local/bin/wp config get {{ constant }} 2>/dev/null)
        && [ "$value" = "$(php -r "echo {{ value }};")" ]
    - require:
      - file: wp-cli
      - user: {{ user }}_user_exists
{% endfor %}

{% for name in mu_plugins %}
/home/{{ user }}/public_html/wp-content/mu-plugins/opencontracting-{{ name }}.php:
  file.managed:
    - source: salt://cms/files/mu-plugins/{{ name }}.php
    - template: jinja
    - context: {{ entry.context|yaml }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists
{% endfor %}

{% set checks = entry.checks|default({}) %}
{% set enabled = checks.enabled|default([]) %}
{% set wp = '/usr/local/bin/wp --no-color --path=' ~ userdir ~ '/public_html' %}
{% if 'integrity' in enabled %}
# The must-use plugins above have no checksums at wordpress.org.
{% set exclude = checks.premium_plugins|default([]) + mu_plugins|map('regex_replace', '^', 'opencontracting-')|list %}

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
{% endif %}

{% set parts = ['updates', 'silent']|select('in', enabled)|list %}
{% if parts %}
WordPress updates check for {{ user }}:
  cron.present:
    - name: {{ wp }} eval-file /usr/local/lib/wp-cli/check-updates.php {{ parts|join(' ') }}
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
