{% set php_version = pillar.php.version|default('8.1')|quote %}

include:
  - apache.modules.proxy_fcgi

php-fpm:
  pkg.installed:
    - name: php{{ php_version }}-fpm
  file.rename:
    - name: /etc/php/{{ php_version }}/fpm/pool.d/www.conf.disabled
    - source: /etc/php/{{ php_version }}/fpm/pool.d/www.conf
    - require:
      - pkg: php-fpm
  service.running:
    - name: php{{ php_version }}-fpm
    - enable: True
    - require:
      - pkg: php-fpm

php-fpm-reload:
  module.wait:
    - name: service.reload
    - m_name: php{{ php_version }}-fpm.service

/var/log/php-fpm:
  file.directory:
    - name: /var/log/php-fpm/
    - makedirs: True

/etc/logrotate.d/php-site-logs:
  file.managed:
    - name: /etc/logrotate.d/php-site-logs
    - source: salt://logrotate/files/php-site-logs
    - template: jinja
    - context:
        php_version: {{ php_version }}
    - require:
      - pkg: php-fpm
      - file: /var/log/php-fpm

{% for name, entry in pillar.phpfpm.sites.items() %}
/var/log/php-fpm/{{ entry.context.user }}:
  file.directory:
    - name: /var/log/php-fpm/{{ entry.context.user }}
    - user: {{ entry.context.user }}
    - group: {{ entry.context.user }}
    - makedirs: True
    - require:
      - file: /var/log/php-fpm

/etc/php/-/fpm/pool.d/{{ name }}.conf:
  file.managed:
    - name: /etc/php/{{ php_version }}/fpm/pool.d/{{ name }}.conf
    - source: salt://php-fpm/files/{{ entry.configuration }}.conf
    - template: jinja
    - context: {{ entry.context|yaml }}
    - require:
      - pkg: php-fpm
      - file: /var/log/php-fpm/{{ entry.context.user }}
    - watch_in:
      - module: php-fpm-reload
{% endfor %}

php modules:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}-curl
      - php{{ php_version }}-imagick
      - php{{ php_version }}-intl
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-mysql
      - php{{ php_version }}-xml
      - php{{ php_version }}-zip
    - watch_in:
      - service: php-fpm
