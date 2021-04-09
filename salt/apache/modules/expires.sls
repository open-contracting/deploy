include:
  - apache

expires:
  apache_module.enabled:
    - watch_in:
      - service: apache2
