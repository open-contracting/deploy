# Add SSL directives.
# https://httpd.apache.org/docs/current/mod/mod_ssl.html

include:
  - apache

ssl:
  apache_module.enabled:
    - watch_in:
      - service: apache2
