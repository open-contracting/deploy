{% from 'lib.sls' import createuser, apache %}

include:
  - apache.public
  - apache.modules.proxy_http

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

/home/{{ user }}/web/:
  file.directory:
    - user: {{ user }}
    - makedirs: True

/home/ocds-docs/web/robots.txt:
  file.managed:
    - source: salt://apache/files/docs/robots.txt
    - user: ocds-docs

/home/ocds-docs/web/includes/:
  file.recurse:
    - source: salt://apache/files/docs/includes
    - user: ocds-docs

# These will be served the same as files that were copied into place.
https://github.com/open-contracting/standard-legacy-staticsites.git:
  git.latest:
    - rev: master
    - target: /home/ocds-docs/web/legacy/
    - user: ocds-docs
    - force_fetch: True
    - force_reset: True

# For information on the testing virtual host, see:
# https://ocdsdeploy.readthedocs.io/en/latest/develop/update.html#using-a-testing-virtual-host

{{ apache('docs',
    name='ocds-docs-live',
    servername='standard.open-contracting.org',
    https=pillar.apache.https,
    extracontext='testing: False') }}

{{ apache('docs',
    name='ocds-docs-live-testing',
    servername='testing.live.standard.open-contracting.org',
    https=pillar.apache.https,
    extracontext='testing: True') }}

# This sets up redirects and an archived opendatacomparison static site for ocds.open-contracting.org,
# which has been replaced by standard.open-contracting.org

{% set legacy = 'opencontracting' %}
{{ createuser(legacy) }}

https://github.com/open-contracting/opendatacomparison-archive.git:
  git.latest:
    - rev: live
    - target: /home/{{ legacy }}/opendatacomparison-archive/
    - user: {{ legacy }}
    - require:
      - pkg: git
    - watch_in:
      - service: apache2

{{ apache('docs-legacy', name='ocds-legacy', servername='ocds.open-contracting.org') }}
