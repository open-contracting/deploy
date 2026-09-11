{% set supported_releases = {
    22: 'php8.1',
    24: 'php8.3',
    26: 'php8.5'
} %}

{% if grains.osmajorrelease in supported_releases %}
  {% set php_version = supported_releases[grains.osmajorrelease] %}
{% else %}
  {% do raise('PHP install failed, unsupported Ubuntu release: ' ~ grains.osmajorrelease) %}
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

/var/log/php-fpm:
  file.directory:
    - makedirs: True

{% for name, entry in pillar.phpfpm.sites|items %}
/var/log/php-fpm/{{ name }}:
  file.directory:
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
    - context: {{ dict(name=name, **entry.context)|yaml }}
    - require:
      - pkg: php-fpm
      - file: /var/log/php-fpm/{{ name }}
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
