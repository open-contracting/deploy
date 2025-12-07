# https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/restoring-original-visitor-ips/
include:
  - apache
  - apache.modules.remoteip

/etc/apache2/conf-enabled/zz-cloudflare-proxy.conf:
  file.managed:
    - contents: |
        RemoteIPHeader CF-Connecting-IP
{%- for ip in salt.cmd.run('curl -sS https://www.cloudflare.com/ips-v4/').split() %}
        RemoteIPTrustedProxy {{ ip }}
{%- endfor %}
{%- for ip in salt.cmd.run('curl -sS https://www.cloudflare.com/ips-v6/').split() %}
        RemoteIPTrustedProxy {{ ip }}
{%- endfor %}
    - require:
      - pkg: apache2
    - watch_in:
      - module: apache2-reload
