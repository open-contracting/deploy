# Defines common macros.

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
{% macro apache(conffile, name='', extracontext='', servername='', serveraliases=[], https='') %}

{% if name == '' %}
{% set name = conffile %}
{% endif %}

{% if servername == '' %}
{% set servername = grains.fqdn %}
{% endif %}

{% if https == 'both' or https == 'force' or https == 'certonly' %}

/etc/apache2/sites-available/{{ name }}.include:
  file.managed:
    - source: salt://apache/{{ conffile }}.include
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: apache2
    - context:
        https: {{ https }}
        {{ extracontext|indent(8) }}

/etc/apache2/sites-available/{{ name }}:
  file.managed:
    - source: salt://apache/_common.conf
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: apache2
    - context:
        includefile: {{ name }}.include
        servername: {{ servername }}
        serveraliases: {{ serveraliases|yaml }}
        https: {{ https }}
        {{ extracontext|indent(8) }}

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
      - file: /etc/apache2/sites-available/{{ name }}
      - file: /etc/apache2/sites-available/{{ name }}.include
      - file: /etc/apache2/sites-enabled/{{ name }}
      # The next line refers to something in salt/letsencrypt.sls
      - file: /var/www/html/.well-known/acme-challenge
    - watch_in:
      - service: apache2

{% else %}

/etc/apache2/sites-available/{{ name }}:
  file.managed:
    - source: salt://apache/{{ conffile }}
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: apache2
    - context:
        includefile: /etc/apache2/sites-available/{{ name }}.include
        servername: {{ servername }}
        serveraliases: {{ serveraliases|yaml }}
        https: "{{ https }}"
        {{ extracontext|indent(8) }}

{% endif %}

/etc/apache2/sites-enabled/{{ name }}:
  file.symlink:
    - target: /etc/apache2/sites-available/{{ name }}
    - require:
      - file: /etc/apache2/sites-available/{{ name }}
    - makedirs: True
    - watch_in:
      - service: apache2

{% endmacro %}


{% macro uwsgi(conffile, name, port='', extracontext='') %}

/etc/uwsgi/apps-available/{{ name }}:
  file.managed:
    - source: salt://uwsgi/{{ conffile }}
    - template: jinja
    - makedirs: True
    - watch_in:
      - service: uwsgi
    - context:
        port: {{ port }}
        {{ extracontext|indent(8) }}

/etc/uwsgi/apps-enabled/{{ name }}:
  file.symlink:
    - target: /etc/uwsgi/apps-available/{{ name }}
    - require:
      - file: /etc/uwsgi/apps-available/{{ name }}
    - makedirs: True
    - watch_in:
      - service: uwsgi

{% endmacro %}
