# Add SSL directives.
# https://httpd.apache.org/docs/current/mod/mod_ssl.html

{% from 'lib.sls' import apache_conf %}

include:
  - apache

ssl:
  apache_module.enabled:
    - watch_in:
      - service: apache2

http2:
  apache_module.enabled:
    - watch_in:
      - service: apache2

{{ apache_conf("ssl-intermediate") }}

