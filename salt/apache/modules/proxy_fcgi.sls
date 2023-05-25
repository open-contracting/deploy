include:
  - apache
  - apache.modules.proxy

proxy_fcgi:
  apache_module.enabled:
    - watch_in:
      - service: apache2
