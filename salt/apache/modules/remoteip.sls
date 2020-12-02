# Add RemoteIPHeader, RemoteIPTrustedProxy and other directives.
# https://httpd.apache.org/docs/current/en/mod/mod_remoteip.html

include:
  - apache

remoteip:
  apache_module.enabled:
    - watch_in:
      - service: apache2
