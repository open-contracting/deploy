# Provide support for the uWSGI protocol in ProxyPass directives.
# https://httpd.apache.org/docs/current/en/mod/mod_proxy_uwsgi.html

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
