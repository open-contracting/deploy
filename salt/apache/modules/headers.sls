include:
  - apache

headers:
  apache_module.enabled:
    - watch_in:
      - service: apache2
