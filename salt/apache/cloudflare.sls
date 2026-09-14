# https://developers.cloudflare.com/support/troubleshooting/restoring-visitor-ips/restoring-original-visitor-ips/
include:
  - apache
  - apache.modules.remoteip

{% set proxied = salt['pillar.get']('apache:proxied') %}
{%- if proxied %}
{#- The certificate authority of the client certificate that Cloudflare presents to the origin server.
    https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/ #}
{%- set authority = salt.cmd.run('curl -sS https://developers.cloudflare.com/ssl/static/authenticated_origin_pull_ca.pem') %}
{% if 'BEGIN CERTIFICATE' in authority %}
/etc/ssl/certs/cloudflare-origin-pull-ca.pem:
  file.managed:
    - contents: |
        {{ authority|indent(8) }}
    - watch_in:
      - module: apache2-reload
{% else %}
{#- Keep any certificate downloaded earlier, rather than write an empty file, which Apache can't load. #}
/etc/ssl/certs/cloudflare-origin-pull-ca.pem:
  file.exists
{% endif %}
{% endif %}

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
{%- if proxied %}
        <IfModule ssl_module>
            # Reject any connection that doesn't present Cloudflare's client certificate. This is set outside the
            # virtual hosts, because the certificate is verified during the TLS handshake, which HTTP/2 can't
            # renegotiate. Port 80 stays open, to redirect to HTTPS and to answer Let's Encrypt's challenges.
            SSLVerifyClient require
            SSLVerifyDepth 1
            SSLCACertificateFile /etc/ssl/certs/cloudflare-origin-pull-ca.pem
        </IfModule>
{%- endif %}
    - require:
      - pkg: apache2
{%- if proxied %}
      - file: /etc/ssl/certs/cloudflare-origin-pull-ca.pem
{%- endif %}
    - watch_in:
      - module: apache2-reload

enable-conf-zz-cloudflare-proxy.conf:
  apache_conf.enabled:
    - name: zz-cloudflare-proxy
    - require:
      - file: /etc/apache2/conf-available/zz-cloudflare-proxy.conf
    - watch_in:
      - module: apache2-reload
