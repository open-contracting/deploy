{% from 'lib.sls' import apache, set_firewall, unset_firewall %}

{% if salt['pillar.get']('apache:public_access') %}
  {{ set_firewall("PUBLIC_HTTP") }}
  {{ set_firewall("PUBLIC_HTTPS") }}
{% else %}
  {{ unset_firewall("PUBLIC_HTTP") }}
  {{ unset_firewall("PUBLIC_HTTPS") }}
{% endif %}

# ondrej/apache2 is still needed on Ubuntu 20.04 for MDContactEmail.
# https://github.com/icing/mod_md/issues/203
apache2:
  {% if grains.osmajorrelease in ("18", "20") %}
  pkgrepo.managed:
    - ppa: ondrej/apache2
  {% endif %}
  pkg.installed:
    - pkgs:
      - apache2
    {% if grains.osmajorrelease in ("18", "20") %}
      # Avoid "AH01882: Init: this version of mod_ssl was compiled against a newer library (OpenSSL 1.1.1g 21 Apr 2020,
      # version currently loaded is OpenSSL 1.1.1 11 Sep 2018) - may result in undefined or erroneous behavior"
      # https://github.com/open-contracting/deploy/issues/66#issuecomment-742898193
      - libssl1.1
      - openssl
    - require:
      - pkgrepo: apache2
    {% endif %}
  service.running:
    - name: apache2
    - enable: True
    - require:
      - pkg: apache2

# This uses the old style. It's not clear how to opt-in to the new style when using Agentless Salt.
# https://docs.saltproject.io/en/latest/ref/states/all/salt.states.module.html
apache2-reload:
  module.wait:
    - name: service.reload
    - m_name: apache2

# https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.webutil.html
apache2-utils:
  pkg.installed:
    - name: apache2-utils

{% if salt['pillar.get']('apache:ipv4') %}
/etc/apache2/ports.conf:
  file.managed:
    - source: salt://apache/files/ports.conf
    - template: jinja
    - require:
      - pkg: apache2
    - watch_in:
      - service: apache2
{% endif %}

# For comparison, /var/www/html/index.html is 644 and owned by root.
/var/www/html/404.html:
  file.managed:
    - source: salt://apache/files/404.html

{{ apache('default', {'configuration': 'default', 'servername': ''}) }}

autoindex:
  apache_module.disabled:
    - watch_in:
      - service: apache2

disable default site:
  apache_site.disabled:
    - name: 000-default
  file.absent:
    - name: /var/www/html/index.html

{% for name, entry in salt['pillar.get']('apache:sites', {}).items() %}
{{ apache(name, entry) }}
{% endfor %}

{% if salt['pillar.get']('apache:wait_for_networking') %}
# Delay the Apache start up if the server has multiple IP addresses.
/etc/systemd/system/apache2.service.d/customization.conf:
  file.managed:
    - source: salt://core/systemd/files/apache2.conf
    - makedirs: True
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/apache2.service.d/customization.conf
{% endif %}
