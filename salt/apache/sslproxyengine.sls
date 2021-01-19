include:
  - apache

/etc/apache2/conf-available/sslproxyengine.conf:
  file.managed:
    - source: salt://apache/files/conf/sslproxyengine.conf
    - require:
      - pkg: apache2
    - watch_in:
      - module: apache2-reload

enable-sslproxyengine-conf:
  apache_conf.enabled:
    - name: sslproxyengine
    - require:
      - file: /etc/apache2/conf-available/sslproxyengine.conf
    - watch_in:
      - module: apache2-reload
