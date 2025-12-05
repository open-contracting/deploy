{% from 'lib.sls' import apache, set_firewall, unset_firewall %}

{% if salt['pillar.get']('apache:public_access') %}
  {{ set_firewall('PUBLIC_HTTP') }}
  {{ set_firewall('PUBLIC_HTTPS') }}
{% else %}
  {{ unset_firewall('PUBLIC_HTTP') }}
  {{ unset_firewall('PUBLIC_HTTPS') }}
{% endif %}

# ondrej/apache2 is still needed on Ubuntu 20.04 for MDContactEmail.
# https://github.com/icing/mod_md/issues/203
apache2:
  {% if grains.osmajorrelease in ('18', '20') %}
  pkgrepo.managed:
    - ppa: ondrej/apache2
  {% endif %}
  pkg.installed:
    - pkgs:
      - apache2
    {% if grains.osmajorrelease in ('18', '20') %}
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

# Ensure this configuration is loaded first.
{{ apache('00-default', {'configuration': 'default', 'servername': ''}) }}
{{ apache('fqdn', {'configuration': 'default', 'servername': grains.fqdn}) }}

{% if salt['pillar.get']('apache:modules:mod_autoindex:enabled') %}
autoindex:
  apache_module.enabled:
    - watch_in:
      - service: apache2
{% else %}
# apache_module.disabled doesn't allow --force.
disable module autoindex:
  file.absent:
    - names:
      - /etc/apache2/mods-enabled/autoindex.conf
      - /etc/apache2/mods-enabled/autoindex.load
{% endif %}

disable site 000-default.conf:
  apache_site.disabled:
    - name: 000-default
    - watch_in:
      - module: apache2-reload
  file.absent:
    - name: /var/www/html/index.html

# Use "zz-" to ensure this configuration is loaded after security.conf and other-vhosts-access-log.conf,
# provided by the package, which set ServerTokens, ServerSignature and CustomLog.
#
# - Do not disclose the Apache version, to avoid false positives about CVE patching.
# - Do not log uptime monitoring remote requests and Netdata's mod_status requests, to reduce log noise.
# - Update LogFormat to use client ip (%a), this allows us to record the client IP through a proxy.
#
# https://httpd.apache.org/docs/2.4/logs.html#conditional
/etc/apache2/conf-available/zz-customization.conf:
  file.managed:
    - contents: |
        ServerTokens Prod
        ServerSignature Off
        SetEnvIf User-Agent AppBeat dontlog
        SetEnvIf User-Agent Pingdom.com_bot dontlog
        SetEnvIf Request_URI "^/server-status$" dontlog
        LogFormat "%v:%p %a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined
        LogFormat "%a %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" combined
        CustomLog ${APACHE_LOG_DIR}/other_vhosts_access.log vhost_combined env=!dontlog
        {{ salt['pillar.get']('apache:customization','') | indent(8) }}
    - require:
      - pkg: apache2
    - watch_in:
      - module: apache2-reload

enable-conf-zz-customization.conf:
  apache_conf.enabled:
    - name: zz-customization
    - require:
      - file: /etc/apache2/conf-available/zz-customization.conf
    - watch_in:
      - module: apache2-reload

disable-conf-other-vhosts-access-log.conf:
  apache_conf.disabled:
    - name: other-vhosts-access-log.conf
    - require:
      - apache_conf: enable-conf-zz-customization.conf
    - watch_in:
      - module: apache2-reload

{% for name, entry in salt['pillar.get']('apache:sites', {})|items %}
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
