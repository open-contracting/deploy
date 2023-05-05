include:
  - apache.modules.proxy_fcgi

php-fpm:
  pkg.installed:
    - name: php{{ pillar.php.version }}-fpm
  file.rename:
    - name: /etc/php/{{ pillar.php.version }}/fpm/pool.d/www.conf.disabled
    - source: /etc/php/{{ pillar.php.version }}/fpm/pool.d/www.conf
    - require:
      - pkg: php-fpm
  service.running:
    - name: php{{ pillar.php.version }}-fpm
    - enable: True
    - require:
      - pkg: apache2

php-fpm-reload:
  module.wait:
    - name: service.reload
    - m_name: php{{ pillar.php.version }}-fpm.service

{% for name, entry in pillar.phpfpm.sites.items() %}
/etc/php/-/fpm/pool.d/{{ name }}.conf:
  file.managed:
    - name: /etc/php/{{ pillar.php.version }}/fpm/pool.d/{{ name }}.conf
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
      - php{{ pillar.php.version }}-curl
      - php{{ pillar.php.version }}-mbstring
      - php{{ pillar.php.version }}-mysql
      - php{{ pillar.php.version }}-xml
    - watch_in:
      - service: php-fpm
