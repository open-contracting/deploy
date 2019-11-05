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
# https://ocdsdeploy.readthedocs.io/en/latest/how-to/update.html#using-a-testing-virtual-host

{% set extracontext %}
testing: False
{% endset %}
{{ apache('ocds-docs-' + pillar.apache.environment + '.conf',
    name='ocds-docs-' + pillar.apache.environment + '.conf',
    servername=pillar.apache.subdomain + 'standard.open-contracting.org',
    extracontext=extracontext,
    https=pillar.apache.https) }}

{% set extracontext %}
testing: True
{% endset %}
{{ apache('ocds-docs-' + pillar.apache.environment + '.conf',
    name='ocds-docs-' + pillar.apache.environment + '-testing.conf',
    servername='testing.' + pillar.apache.environment + '.standard.open-contracting.org',
    extracontext=extracontext,
    https=pillar.apache.https) }}
