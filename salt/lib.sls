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

{{ user }}_root_authorized_keys_remove:
  ssh_auth.absent:
   - user: {{ user }}
   - source: salt://private/authorized_keys/root_to_remove
   - require:
     - user: {{ user }}_user_exists

{% for auth_keys_file in auth_keys_files %}

{{ user }}_{{ auth_keys_file }}_authorized_keys_add:
  ssh_auth.present:
   - user: {{ user }}
   - source: salt://private/authorized_keys/{{ auth_keys_file }}_to_add
   - require:
     - user: {{ user }}_user_exists

{{ user }}_{{ auth_keys_file }}_authorized_keys_remove:
  ssh_auth.absent:
   - user: {{ user }}
   - source: salt://private/authorized_keys/{{ auth_keys_file }}_to_remove
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
        {{ extracontext | indent(8) }}

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
        {{ extracontext | indent(8) }}

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
        {{ extracontext | indent(8) }}

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
        {{ extracontext | indent(8) }}

/etc/uwsgi/apps-enabled/{{ name }}:
  file.symlink:
    - target: /etc/uwsgi/apps-available/{{ name }}
    - require:
      - file: /etc/uwsgi/apps-available/{{ name }}
    - makedirs: True
    - watch_in:
      - service: uwsgi

{% endmacro %}


# app: override the DJANGO_SETTINGS_MODULE set in the Django project's manage.py file
{% macro django(name, user, giturl, branch, djangodir, app=None, compilemessages=True) %}

{{ giturl }}{{ djangodir }}:
  git.latest:
    - name: {{ giturl }}
    - rev: {{ branch }}
    - target: {{ djangodir }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - require:
      - pkg: git
    - watch_in:
      - service: uwsgi

# We have seen different permissions on different servers, and we have seen bugs arise as a result.
# (This won't ensure permissions are correct on new files, but it will fix any existing problems.)
{{ djangodir }}media:
  file.directory:
    - name: {{ djangodir }}media
    - user: {{ user }}
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - mode

# Install the latest version of pip, needed to download linux wheels, which avoids building C code.
{{ djangodir }}.ve/-pip:
  virtualenv.managed:
    - name: {{ djangodir }}.ve/
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs: pip==8.1.2
    - require:
      - pkg: {{ user }}-deps
      - git: {{ giturl }}{{ djangodir }}

# Then, install the rest of the requirements.
{{ djangodir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - requirements: {{ djangodir }}requirements.txt
    - require:
      - virtualenv: {{ djangodir }}.ve/-pip
      - file: set_lc_all # required to avoid unicode errors for the "schema" library
    - watch_in:
      - service: apache2

migrate-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; {% if app %}DJANGO_SETTINGS_MODULE={{ app }}.settings {% endif %}python manage.py migrate --noinput
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

{% if compilemessages %}
compilemessages-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; {% if app %}DJANGO_SETTINGS_MODULE={{ app }}.settings {% endif %}python manage.py compilemessages
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}
{% endif %}

collectstatic-{{ name }}:
  cmd.run:
    - name: . .ve/bin/activate; {% if app %}DJANGO_SETTINGS_MODULE={{ app }}.settings {% endif %}python manage.py collectstatic --noinput
    - runas: {{ user }}
    - cwd: {{ djangodir }}
    - require:
      - virtualenv: {{ djangodir }}.ve/
    - onchanges:
      - git: {{ giturl }}{{ djangodir }}

{{ djangodir }}static/:
  file.directory:
    - file_mode: 644
    - dir_mode: 755
    - recurse:
      - mode
    - require:
      - cmd: collectstatic-{{ name }}
    - user: {{ user }}
    - group: {{ user }}

{{ djangodir }}:
  file.directory:
    - dir_mode: 755
    - require:
      - cmd: collectstatic-{{ name }}
    - user: {{ user }}
    - group: {{ user }}

{% endmacro %}
