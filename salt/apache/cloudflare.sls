# https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/restoring-original-visitor-ips/
include:
  - apache
  - apache.modules.remoteip

/etc/apache2/conf-available/zz-cloudflare-proxy.conf:
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

enable-conf-zz-cloudflare-proxy.conf:
  apache_conf.enabled:
    - name: zz-cloudflare-proxy
    - require:
      - file: /etc/apache2/conf-available/zz-cloudflare-proxy.conf
    - watch_in:
      - module: apache2-reload
