{% from 'lib.sls' import createuser %}

include:
  - apache

{% set user = 'ocds-docs' %}
{{ createuser(user, authorized_keys=pillar.ssh.docs) }}

# Needed to create a ZIP file of the schema and codelists.
# https://ocdsdeploy.readthedocs.io/en/latest/deploy/docs.html#copy-the-schema-and-zip-file-into-place
zip:
  pkg.installed

docs modules:
  apache_module.enabled:
    - names:
      - headers
      - include
      - rewrite
      - substitute
    - watch_in:
      - service: apache2

/var/www/html/robots.txt:
  file.managed:
    - source: salt://apache/files/docs/robots_disallow.txt
    - require:
      - pkg: apache2

/home/{{ user }}/web:
  file.directory:
    - user: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists

/home/{{ user }}/web/robots.txt:
  file.managed:
    - source: salt://apache/files/docs/robots.txt
    - user: {{ user }}
    - require:
      - file: /home/{{ user }}/web

/home/{{ user }}/web/includes:
  file.recurse:
    - source: salt://apache/files/docs/includes
    - user: {{ user }}
    - require:
      - file: /home/{{ user }}/web

# These will be served the same as files that were copied into place.
https://github.com/open-contracting/standard-legacy-staticsites.git:
  git.latest:
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: /home/{{ user }}/web/legacy/
    - require:
      - pkg: git
      - file: /home/{{ user }}/web

# This sets up redirects and an archived opendatacomparison static site for ocds.open-contracting.org,
# which has been replaced by standard.open-contracting.org

{% set legacy = 'opencontracting' %}
{{ createuser(legacy) }}

https://github.com/open-contracting/opendatacomparison-archive.git:
  git.latest:
    - user: {{ legacy }}
    - force_fetch: True
    - force_reset: True
    - branch: live
    - rev: live
    - target: /home/{{ legacy }}/opendatacomparison-archive/
    - require:
      - pkg: git
      - user: {{ legacy }}_user_exists
