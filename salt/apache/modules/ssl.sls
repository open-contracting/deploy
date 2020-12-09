# Add SSL directives.
# https://httpd.apache.org/docs/current/mod/mod_ssl.html

{% from 'lib.sls' import apache_simple_config %}

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

{{ apache_simple_config("ssl-intermediate.conf", alt_name="020-ssl-intermediate.conf") }}

