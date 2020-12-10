{% from 'lib.sls' import apache, set_firewall, unset_firewall %}

{% if salt['pillar.get']('apache:public_access') %}
  {{ set_firewall("PUBLIC_HTTP") }}
  {{ set_firewall("PUBLIC_HTTPS") }}
{% else %}
  {{ unset_firewall("PUBLIC_HTTP") }}
  {{ unset_firewall("PUBLIC_HTTPS") }}
{% endif %}

apache2:
  pkg.installed:
    - name: apache2
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2

{% if salt['pillar.get']('apache:sites') %}
{% for name, entry in pillar.apache.sites.items() %}
{{ apache(name, entry) }}
{% endfor %}
{% endif %}
