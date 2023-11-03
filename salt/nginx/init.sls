{% from 'lib.sls' import set_firewall, unset_firewall %}

{% if salt['pillar.get']('nginx:public_access') %}
  {{ set_firewall("PUBLIC_HTTP") }}
  {{ set_firewall("PUBLIC_HTTPS") }}
{% else %}
  {{ unset_firewall("PUBLIC_HTTP") }}
  {{ unset_firewall("PUBLIC_HTTPS") }}
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

/etc/nginx/conf.d/zz-customization.conf:
  file.managed:
    - contents: |
        server_tokens off;
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload

{% for name, entry in salt['pillar.get']('nginx:sites', {}).items() %}
/etc/nginx/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://nginx/files/sites/{{ entry.configuration }}.conf
    - template: jinja
    - context:
        servername: {{ entry.servername }}
        serveraliases: {{ entry.serveraliases|default([])|yaml }}
    - require:
      - pkg: nginx
    - watch_in:
      - module: nginx-reload

/etc/nginx/sites-enabled/{{ name }}.conf:
  file.symlink:
    - target: /etc/nginx/sites-available/{{ name }}.conf
{% endfor %}
