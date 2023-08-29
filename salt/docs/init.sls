{% from 'lib.sls' import create_user %}

include:
  - apache
  # docs.conf.include
  - apache.modules.headers # Header
  - apache.modules.proxy_http # ProxyPass
  - apache.modules.rewrite # RewriteEngine

{% set user = 'ocds-docs' %}
{% set userdir = '/home/' + user %}

{{ create_user(user, authorized_keys=pillar.ssh.docs) }}

# Needed to create a ZIP file of the schema and codelists.
# https://ocdsdeploy.readthedocs.io/en/latest/deploy/docs.html#copy-the-schema-and-zip-file-into-place
zip:
  pkg.installed:
    - name: zip

docs modules:
  apache_module.enabled:
    - names:
      - include
      - substitute
    - watch_in:
      - service: apache2

/var/www/html/robots.txt:
  file.managed:
    - source: salt://apache/files/docs/robots_disallow.txt
    - require:
      - pkg: apache2

# It is insufficient to give Apache permission to /home/ocds-docs/web only.
allow Apache access to {{ userdir }}:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/web:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/web/robots.txt:
  file.managed:
    - source: salt://apache/files/docs/robots.txt
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: {{ userdir }}/web

{{ userdir }}/web/includes:
  file.recurse:
    - source: salt://apache/files/docs/includes
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - file: {{ userdir }}/web

{{ userdir }}/1-size.sh:
  file.managed:
    - source: salt://docs/files/size.sh
    - user: {{ user }}
    - group: {{ user }}
    - mode: 700
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/2-delete.sh:
  file.managed:
    - source: salt://docs/files/delete.sh
    - user: {{ user }}
    - group: {{ user }}
    - mode: 700
    - require:
      - user: {{ user }}_user_exists
