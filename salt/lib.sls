# Defines common macros.

{% macro set_firewall(setting_name, setting_value="yes") %}
set {{ setting_name }} firewall setting:
  file.replace:
    - name:  /home/sysadmin-tools/firewall-settings.local
    - pattern: "{{ setting_name }}=.*"
    - repl: "{{ setting_name }}=\"{{ setting_value }}\""
    - append_if_not_found: True
    - backup: ""
{% endmacro %}

{% macro unset_firewall(setting_name) %}
unset {{ setting_name }} firewall setting:
  file.replace:
    - name:  /home/sysadmin-tools/firewall-settings.local
    - pattern: "{{ setting_name }}=.*"
    - repl: "{{ setting_name }}=\"\""
    - ignore_if_missing: True
    - backup: ""
{% endmacro %}


# Our policy is to run as much as possible as unprivileged users. Therefore, most states start by creating a user.
{% macro createuser(user, authorized_keys=[]) %}

{{ user }}_user_exists:
  user.present:
    - name: {{ user }}
    - home: /home/{{ user }}
    - order: 1
    - shell: /bin/bash

{{ user }}_authorized_keys:
  ssh_auth.manage:
    - user: {{ user }}
    - ssh_keys: {{ (pillar.ssh.admin + salt['pillar.get']('ssh:root', []) + authorized_keys)|yaml }}
    - require:
      - user: {{ user }}_user_exists

{% endmacro %}


# It is safe to use `{}` as a default value, because the default value is never mutated.
{% macro apache_site_config(name, entry, context={}) %}

{% set https = entry.get('https', '') %}
{% set serveraliases = entry.get('serveraliases', []) %}

{% if not context %}
  {% set context = entry.get('context', {}) %}
{% endif %}

{% if https == 'force' %}
  {% set ports = [80, 443] %}
{% else %} {# https == 'certonly', used to serve /.well-known/acme-challenge over HTTP, or turned off #}
  {% set ports = [80] %}
{% endif %}

/etc/apache2/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://apache/files/site-configs/{{ entry.configuration }}.conf.include
    - template: jinja
    - context: {{ context|yaml }}
    - makedirs: True
    - watch_in:
      - service: apache2

/etc/apache2/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/files/_common.conf
    - template: jinja
    - context:
        includefile: /etc/apache2/sites-available/{{ name }}.conf.include
        servername: {{ entry.servername }}
        serveraliases: {{ serveraliases|yaml }}
        https: "{{ https }}"
        ports: {{ ports|yaml }}
    - makedirs: True
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
    - watch_in:
      - service: apache2

{% if https == 'force' or https == 'certonly' %}

{% set domainargs = "-d " + " -d ".join([entry.servername] + serveraliases) %}

{{ entry.servername }}_acquire_certs:
  cmd.run:
    - name: apache2ctl -k graceful; /snap/bin/certbot certonly --non-interactive --no-self-upgrade --expand --email sysadmin@open-contracting.org --agree-tos --webroot --webroot-path /usr/local/share/ocp-letsencrypt/ {{ domainargs }}
    - creates:
      - /etc/letsencrypt/live/{{ entry.servername }}/cert.pem
      - /etc/letsencrypt/live/{{ entry.servername }}/chain.pem
      - /etc/letsencrypt/live/{{ entry.servername }}/fullchain.pem
      - /etc/letsencrypt/live/{{ entry.servername }}/privkey.pem
    - require:
      # Require certbot doesn't work for some reason
      #- file: /snap/bin/certbot
      - file: /etc/apache2/sites-available/{{ name }}.conf
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
      - file: /etc/apache2/sites-enabled/{{ name }}.conf
      - file: /etc/apache2/sites-enabled/010-letsencrypt.conf
      - file: /usr/local/share/ocp-letsencrypt/.well-known/acme-challenge
    - watch_in:
      - service: apache2

{% endif %}

enable {{ name }} site:
  apache_site.enabled:
    - name: {{ name }}

{% endmacro %}

{% macro apache_conf(name) %}

/etc/apache2/conf-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/files/apache-configs/{{ name }}.conf

enable {{ name }} conf:
  apache_conf.enabled:
    - name: {{ name }}

{% endmacro %}


{#
  Accepts a `name` parameter, which must match the repository name of a Prometheus component: for example, prometheus.

  The macro reads Pillar data from the `prometheus.{name}` key. The variables below refer to keys in this Pillar data.

  The macro creates states to:

  - Download and extract the specified `version` of the named component to the `user`'s home directory
  - Create `config`uration files in the user's home directory, if any
  - Create a systemd `service` file from a `salt/prometheus/files/systemd/{service}.service` template,
    with access to `name`, `user` and `entry` variables
  - Start the `service`
#}
{% macro prometheus_service(name) %}

{% set entry = pillar.prometheus[name] %}
{% set userdir = '/home/' + entry.user %}

{{ createuser(entry.user) }}

# Note: This does not clean up old versions.
extract_{{ name }}:
  archive.extracted:
    - name: {{ userdir }}
    - source: https://github.com/prometheus/{{ name }}/releases/download/v{{ entry.version }}/{{ name }}-{{ entry.version }}.{{ grains.kernel|lower }}-{{ grains.osarch }}.tar.gz
    - source_hash: https://github.com/prometheus/{{ name }}/releases/download/v{{ entry.version }}/sha256sums.txt
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists

{% for filename, source in entry.config.items() %}
{{ userdir }}/{{ filename }}:
  file.managed:
    - source: {{ source }}
    - template: jinja
    - context:
        user: {{ entry.user }}
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists
    # Make sure the service restarts if a configuration file changes.
    - watch_in:
      - service: {{ entry.service }}
{% endfor %}

# https://github.com/prometheus/node_exporter/tree/master/examples/systemd
/etc/systemd/system/{{ entry.service }}.service:
  file.managed:
    - source: salt://prometheus/files/systemd/{{ entry.service }}.service
    - template: jinja
    - context:
        name: {{ name }}
        user: {{ entry.user }}
        entry: {{ entry|yaml }}
    - watch_in:
      - service: {{ entry.service }}

{{ entry.service }}:
  service.running:
    - enable: True
    - restart: True
    - require:
      - archive: extract_{{ name }}
      - file: /etc/systemd/system/{{ entry.service }}.service

{% endmacro %}
