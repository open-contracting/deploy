include:
  - apache

apache-proxy modules:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http
      - headers
    - watch_in:
      - service: apache2
