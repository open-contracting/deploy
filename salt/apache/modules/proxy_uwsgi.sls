include:
  - apache
  - apache.modules.proxy

proxy_uwsgi:
  apache_module.enabled:
    - watch_in:
      - service: apache2
    - require:
      - pkg: libapache2-mod-proxy-uwsgi

libapache2-mod-proxy-uwsgi:
  pkg.installed
