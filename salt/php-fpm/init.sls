{% set php_versions = {
    22: '8.1',
    24: '8.3',
    26: '8.5',
} %}

{% if grains.osmajorrelease in php_versions %}
  {% set php_version = php_versions[grains.osmajorrelease] %}
{% else %}
  {% do raise('Unrecognized Ubuntu release: ' ~ grains.osmajorrelease) %}
{% endif %}

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

{% if pillar.php.opcache is defined %}
/etc/php/-/fpm/conf.d/99-opcache.ini:
  file.managed:
    - name: /etc/php/{{ php_version }}/fpm/conf.d/99-opcache.ini
    - source: salt://php-fpm/files/opcache.ini
    - template: jinja
    - context: {{ pillar.php.opcache|yaml }}
    - require:
      - pkg: php-fpm
    - watch_in:
      - service: php-fpm
{% endif %}

/var/log/php-fpm:
  file.directory:
    - makedirs: True

{% for site, entry in pillar.phpfpm.sites|items %}
/var/log/php-fpm/{{ site }}:
  file.directory:
    - user: {{ entry.context.user }}
    - group: {{ entry.context.user }}
    - makedirs: True
    - require:
      - file: /var/log/php-fpm

/etc/php/-/fpm/pool.d/{{ site }}.conf:
  file.managed:
    - name: /etc/php/{{ php_version }}/fpm/pool.d/{{ site }}.conf
    - source: salt://php-fpm/files/{{ entry.configuration }}.conf
    - template: jinja
    - context: {{ dict(site=site, name=site, **entry.context)|yaml }}
    - require:
      - pkg: php-fpm
      - file: /var/log/php-fpm/{{ site }}
    - watch_in:
      - module: php-fpm-reload
{% endfor %}

php-fpm-config-test:
  cmd.run:
    - name: /usr/sbin/php-fpm{{ php_version }} -t
    - onchanges:
{%- for site in pillar.phpfpm.sites %}
      - file: /etc/php/-/fpm/pool.d/{{ site }}.conf
{%- endfor %}
    - require_in:
      - module: php-fpm-reload

php modules:
  pkg.installed:
    - pkgs:
      - php{{ php_version }}-curl
      - php{{ php_version }}-imagick
      - php{{ php_version }}-intl
      - php{{ php_version }}-mbstring
      - php{{ php_version }}-mysql
      - php{{ php_version }}-redis
      - php{{ php_version }}-xml
      - php{{ php_version }}-zip
    - watch_in:
      - service: php-fpm
