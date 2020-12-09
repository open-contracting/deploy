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


# It is safe to use `[]` as a default value, because the default value is never mutated.
{% macro apache(conffile, name='', servername='', serveraliases=[], https='', extracontext='', ports=[]) %}
# servername = FQDN, main host in Apache.


{% if name == '' %}
    {% set name = conffile %}
{% endif %}

{% if servername == '' %}
    {% set servername = grains['fqdn'] %}
{% endif %}

{% if ports == [] %}
    {% if https == 'force' %}
        {% set ports = [80, 443] %}
    {% else %} {# https == 'certonly', used to serve /.well-known/acme-challenge over HTTP, or turned off #}
        {% set ports = [80] %}
    {% endif %}
{% endif %}

/etc/apache2/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://apache/files/{{ conffile }}.conf.include
    - template: jinja
    - context:
        {{ extracontext|indent(8) }}
    - makedirs: True
    - watch_in:
      - service: apache2

/etc/apache2/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/files/_common.conf
    - template: jinja
    - context:
        includefile: /etc/apache2/sites-available/{{ name }}.conf.include
        servername: {{ servername }}
        serveraliases: {{ serveraliases|yaml }}
        https: "{{ https }}"
        ports: {{ ports|yaml }}
    - makedirs: True
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
    - watch_in:
      - service: apache2

{% if https == 'force' or https == 'certonly' %}

{% set domainargs = "-d " + " -d ".join([servername] + serveraliases) %}

{{ servername }}_acquire_certs:
  cmd.run:
    - name: apache2ctl -k graceful; /snap/bin/certbot certonly --non-interactive --no-self-upgrade --expand --email sysadmin@open-contracting.org --agree-tos --webroot --webroot-path /usr/local/share/ocp-letsencrypt/ {{ domainargs }}
    - creates:
      - /etc/letsencrypt/live/{{ servername }}/cert.pem
      - /etc/letsencrypt/live/{{ servername }}/chain.pem
      - /etc/letsencrypt/live/{{ servername }}/fullchain.pem
      - /etc/letsencrypt/live/{{ servername }}/privkey.pem
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

/etc/apache2/sites-enabled/{{ name }}.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/{{ name }}.conf
    - makedirs: True
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf
    - watch_in:
      - service: apache2

{% endmacro %}

{% macro apache_simple_config(name, alt_name='') %}
# Upload config to server and enable
# name = file name in apache/files
# alt_name = name on server 

{% if alt_name == '' %}
    {% set alt_name = name %}
{% endif %}


# Enables .well-known authentication for LE SSL certs
/etc/apache2/sites-available/{{ alt_name }}:
  file.managed:
    - source: salt://apache/files/{{ name }}

/etc/apache2/sites-enabled/{{ alt_name }}:
  file.symlink:
    - target: /etc/apache2/sites-available/{{ alt_name }}
    - require:
      - file: /etc/apache2/sites-available/{{ alt_name }}
    - watch_in:
      - service: apache2
{% endmacro %}


{% macro prometheus_service(name) %}

{% set entry = pillar.prometheus[name] %}
{% set userdir = '/home/' + entry.user %}

{{ createuser(entry.user) }}

# Note: This does not clean up old versions.
extract_{{ name }}:
  archive.extracted:
    - name: {{ userdir }}
    - source: https://github.com/prometheus/{{ name }}/releases/download/v{{ entry.version }}/{{ name }}-{{ entry.version }}.linux-amd64.tar.gz
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
    - source: salt://prometheus/files/{{ entry.service }}.service
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

{% if 'apache' in entry %}
{{ apache(entry.service,
    servername=entry.apache.servername,
    https=entry.apache.https,
    extracontext='user: ' + entry.user) }}
{% endif %}

{% endmacro %}
