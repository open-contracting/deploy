{% from 'lib.sls' import nginx, set_firewall, unset_firewall %}

{% if salt['pillar.get']('nginx:public_access') %}
  {{ set_firewall('PUBLIC_HTTP') }}
  {{ set_firewall('PUBLIC_HTTPS') }}
{% else %}
  {{ unset_firewall('PUBLIC_HTTP') }}
  {{ unset_firewall('PUBLIC_HTTPS') }}
{% endif %}

nginx:
  pkg.installed:
    - name: nginx
  service.running:
    - name: nginx
    - enable: True
    - require:
      - pkg: nginx

nginx-reload:
  module.wait:
    - name: service.reload
    - m_name: nginx

/etc/nginx/nginx.conf:
  file.replace:
    - pattern: worker_connections = \d+;
    - repl: worker_connections 10000;
    - backup: False
    - require:
      - pkg: nginx
    - watch_in:
      - service: nginx

# For comparison, /var/www/html/index.html is 644 and owned by root.
/var/www/html/404.html:
  file.managed:
    - source: salt://apache/files/404.html  # Note: Reuse Apache file.

{{ nginx('00-default', {'configuration': 'ip', 'servername': ''}) }}
{{ nginx('fqdn', {'include': 'default', 'servername': grains.fqdn}) }}

disable site default:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

/etc/nginx/conf.d/zz-customization.conf:
  file.managed:
    - contents: |
        server_tokens off;
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload

{% for name, entry in salt['pillar.get']('nginx:sites', {})|items %}
{{ nginx(name, entry) }}
{% endfor %}
