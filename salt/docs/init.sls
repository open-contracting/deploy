{% from 'lib.sls' import create_user %}

include:
  - apache
  # docs.conf.include
  - apache.modules.headers # Header
  - apache.modules.proxy_http # ProxyPass
  - apache.modules.rewrite # RewriteEngine

{% set user = 'ocds-docs' %}
{% set userdir = '/home/' ~ user %}

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

# Make it easier for root user to administer Elasticsearch.
/root/.netrc:
  file.managed:
    - contents: |
        machine standard.open-contracting.org
        login ocpadmin
        password {{ pillar.elasticsearch.plugins.readonlyrest.password }}
    - template: jinja
    - mode: 600

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

{#-
  The versions that the documentation's version switcher offers, current version first, and their labels.

  This is deliberately not the `versions` list in apache/files/sites/docs.conf.include. That list also names the
  alias directories (/1.1/, /infrastructure/0.9/, /profiles/ppp/1.0/), which are symlinks to the current version's
  directory: they need Apache directives, but readers aren't offered them, and naming them here would make the
  documentation show its old-version banner on them.

  Update this on release. It replaces includes/version-options*.html, which only the frozen /1.0/ still reads.
-#}
{%- set documentation = {
    '': [
        {'ref': 'latest', 'label': '1.1.5 (latest)'},
        {'ref': '1.0', 'label': '1.0.3'},
    ],
    'infrastructure/': [
        {'ref': 'latest', 'label': '0.9.4 (latest)'},
    ],
    'profiles/eforms/': [
        {'ref': 'latest', 'label': 'latest'},
    ],
    'profiles/eu/': [
        {'ref': 'latest', 'label': 'latest'},
    ],
    'profiles/gpa/': [
        {'ref': 'latest', 'label': 'latest'},
    ],
    'profiles/ppp/': [
        {'ref': 'latest', 'label': '1.0.0.beta5 (latest)'},
    ],
} %}
{%- for root, versions in documentation|items %}

{{ userdir }}/web/{{ root }}versions.json:
  file.managed:
    - contents: |
        {{ {'versions': versions}|tojson }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - file: {{ userdir }}/web

# The staging copy offers no versions: its directories are named after the branch that was pushed.
{{ userdir }}/web/staging/{{ root }}versions.json:
  file.managed:
    - contents: |
        {{ {'staging': True, 'live_url': '/' ~ root ~ versions[0].ref ~ '/en/'}|tojson }}
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - file: {{ userdir }}/web
{%- endfor %}

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
