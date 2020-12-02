# Add ProxyPass, ProxyPreserveHost and other directives.
# https://httpd.apache.org/docs/current/en/mod/mod_proxy.html

include:
  - apache

proxy:
  apache_module.enabled:
    - watch_in:
      - service: apache2
