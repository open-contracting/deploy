include:
  - apache

deflate:
  apache_module.enabled:
    - watch_in:
      - service: apache2
