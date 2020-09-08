{% from 'lib.sls' import createuser, apache %}

{% set user = 'ocds-docs' %}
{{ createuser(user) }}

ocds-docs-common modules:
  apache_module.enabled:
    - names:
      - headers
      - include
      - rewrite
      - substitute
    - watch_in:
      - service: apache2

# Create directory into which files are copied into place.
/home/{{ user }}/web/:
  file.directory:
    - user: {{ user }}
    - makedirs: True
    - mode: 755

/home/ocds-docs/web/includes/:
  file.recurse:
    - source: salt://ocds-docs/includes
    - user: ocds-docs

# For information on the testing virtual host, see:
# https://ocdsdeploy.readthedocs.io/en/latest/develop/update.html#using-a-testing-virtual-host

{{ apache('ocds-docs-' + pillar.apache.environment + '.conf',
    name='ocds-docs-' + pillar.apache.environment + '.conf',
    servername=pillar.apache.subdomain + 'standard.open-contracting.org',
    extracontext='testing: False',
    https=pillar.apache.https) }}

{{ apache('ocds-docs-' + pillar.apache.environment + '.conf',
    name='ocds-docs-' + pillar.apache.environment + '-testing.conf',
    servername='testing.' + pillar.apache.environment + '.standard.open-contracting.org',
    extracontext='testing: True',
    https=pillar.apache.https) }}
