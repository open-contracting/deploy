include:
  - nginx

/etc/nginx/conf.d/zz-cloudflare-proxy.conf:
  file.managed:
    - contents: |
        real_ip_header CF-Connecting-IP;
{%- for ip in salt.cmd.run('curl -sS https://www.cloudflare.com/ips-v4/').split() %}
        set_real_ip_from {{ ip }};
{%- endfor %}
{%- for ip in salt.cmd.run('curl -sS https://www.cloudflare.com/ips-v6/').split() %}
        set_real_ip_from {{ ip }};
{%- endfor %}
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload
