# Provide support for HTTP/HTTPS requests in ProxyPass directives.
# https://httpd.apache.org/docs/current/en/mod/mod_proxy_http.html

include:
  - apache
  - apache.modules.proxy

proxy_http:
  apache_module.enabled:
    - watch_in:
      - service: apache2
