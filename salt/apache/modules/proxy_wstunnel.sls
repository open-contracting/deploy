include:
  - apache

proxy_wstunnel:
  apache_module.enabled:
    - watch_in:
      - service: apache2
