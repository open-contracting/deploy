# Defines common macros.

{% macro configurefirewall(setting_name,setting_value="yes") %}
configure firewall setting {{ setting_name }}:
  file.replace:
    - name:  /home/sysadmin-tools/firewall-settings.local
    - pattern: "{{ setting_name }}=.*"
    - repl: "{{ setting_name }}=\"{{setting_value}}\""
    - append_if_not_found: True
    - backup: ""
{% endmacro %}

# Our policy is to run as much as possible as unprivileged users. Therefore, most states start by creating a user.
{% macro createuser(user, auth_keys_files=[]) %}

{{ user }}_user_exists:
  user.present:
    - name: {{ user }}
    - home: /home/{{ user }}
    - order: 1
    - shell: /bin/bash

{{ user }}_root_authorized_keys_add:
  ssh_auth.present:
    - user: {{ user }}
    - source: salt://private/authorized_keys/root_to_add
    - require:
      - user: {{ user }}_user_exists

{% for auth_keys_file in auth_keys_files %}

{{ user }}_{{ auth_keys_file }}_authorized_keys_add:
  ssh_auth.present:
    - user: {{ user }}
    - source: salt://private/authorized_keys/{{ auth_keys_file }}_to_add
    - require:
      - user: {{ user }}_user_exists

{% endfor %}

{% endmacro %}


# It is safe to set `serveraliases=[]`, because the default argument is never mutated.
{% macro apache(conffile, name='', extracontext='', servername='', serveraliases=[], https='', ports=[]) %}

{% if name == '' %}
    {% set name = conffile %}
{% endif %}

{% if servername == '' %}
    {% set servername = grains.fqdn %}
{% endif %}

{% if ports == [] %}
    {% if https == 'both' or https == 'force' %}
        {% set ports = [ '80', '443' ] %}
    {% else %} {# https == 'certonly' or turned off #}
        {% set ports = [ '80' ] %}
    {% endif %}
    {# Note there is a third https mode, certonly! But it is NOT used in setting myportlist #}
    {# In this mode we want to setup /.well-known/acme-challenge BUT NOT the actual SSL site #}
    {# This mode is used when we don't currently have SSL certs but want them. #}
    {# So we can't enable the SSL site (because no certs) but we do want /.well-known/acme-challenge #}
{% endif %}

/etc/apache2/sites-available/{{ name }}.conf.include:
  file.managed:
    - source: salt://apache/{{ conffile }}.conf.include
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: apache2
    - context:
        https: "{{ https }}"
        {{ extracontext|indent(8) }}

/etc/apache2/sites-available/{{ name }}.conf:
  file.managed:
    - source: salt://apache/_common.conf
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: apache2
    - context:
        myportlist: {{ ports|yaml }}
        includefile: /etc/apache2/sites-available/{{ name }}.conf.include
        servername: {{ servername }}
        serveraliases: {{ serveraliases|yaml }}
        https: "{{ https }}"
        {{ extracontext|indent(8) }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf.include

{% if https == 'both' or https == 'force' or https == 'certonly' %}

{% set domainargs = "-d " + " -d ".join([servername] + serveraliases) %}

{{ servername }}_acquire_certs:
  cmd.run:
    - name: /etc/init.d/apache2 reload; letsencrypt certonly --non-interactive --no-self-upgrade --expand --email sysadmin@open-contracting.org --agree-tos --webroot --webroot-path /var/www/html/ {{ domainargs }}
    - creates:
      - /etc/letsencrypt/live/{{ servername }}/cert.pem
      - /etc/letsencrypt/live/{{ servername }}/chain.pem
      - /etc/letsencrypt/live/{{ servername }}/fullchain.pem
      - /etc/letsencrypt/live/{{ servername }}/privkey.pem
    - require:
      - pkg: letsencrypt
      - file: /etc/apache2/sites-available/{{ name }}.conf
      - file: /etc/apache2/sites-available/{{ name }}.conf.include
      - file: /etc/apache2/sites-enabled/{{ name }}.conf
      # The next line refers to something in salt/letsencrypt.sls
      - file: /var/www/html/.well-known/acme-challenge
    - watch_in:
      - service: apache2

{% endif %}

/etc/apache2/sites-enabled/{{ name }}.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/{{ name }}.conf
    - require:
      - file: /etc/apache2/sites-available/{{ name }}.conf
    - makedirs: True
    - watch_in:
      - service: apache2

{% endmacro %}


{% macro uwsgi(conffile, name='', port='', extracontext='') %}

{% if name == '' %}
    {% set name = conffile %}
{% endif %}

/etc/uwsgi/apps-available/{{ name }}.ini:
  file.managed:
    - source: salt://uwsgi/{{ conffile }}.ini
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: uwsgi
    - context:
        port: {{ port }}
        {{ extracontext|indent(8) }}

/etc/uwsgi/apps-enabled/{{ name }}.ini:
  file.symlink:
    - target: /etc/uwsgi/apps-available/{{ name }}.ini
    - require:
      - file: /etc/uwsgi/apps-available/{{ name }}.ini
    - makedirs: True
    - watch_in:
      - service: uwsgi

{% endmacro %}
