include:
  - apache

apache_proxy_salt_file:
  apache_module.enabled:
    - names:
      - proxy
      - proxy_http
      - headers
    - watch_in:
      - service: apache2
