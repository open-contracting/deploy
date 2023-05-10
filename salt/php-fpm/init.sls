{% set php_version = pillar.php.get('version', '8.1') %}

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

{% for name, entry in pillar.phpfpm.sites.items() %}
/etc/php/-/fpm/pool.d/{{ name }}.conf:
  file.managed:
    - name: /etc/php/{{ php_version }}/fpm/pool.d/{{ name }}.conf
    - source: salt://php-fpm/files/{{ entry.configuration }}.conf
    - template: jinja
    - context: {{ entry.context|yaml }}
    - require:
      - pkg: php-fpm
    - watch_in:
      - module: php-fpm-reload
{% endfor %}

php modules:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}-curl
      - php{{ php_version }}-gd
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-mysql
      - php{{ php_version }}-xml
    - watch_in:
      - service: php-fpm
