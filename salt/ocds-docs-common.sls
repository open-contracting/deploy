include:
  - apache-proxy
  - letsencrypt

{% from 'lib.sls' import createuser, apache %}
{% set user = 'ocds-docs' %}
{{ createuser(user) }}

/home/{{ user }}/web/:
  file.directory:
    - user: {{ user }}
    - makedirs: True
    - mode: 755

/home/ocds-docs/web/includes/:
  file.recurse:
    - source: salt://ocds-docs/includes
    - user: ocds-docs

mod_include:
  apache_module.enabled:
    - name: include

rewrite:
  apache_module.enabled

mod_substitute:
  apache_module.enabled:
    - name: substitute

# For information on the testing virtual host, see:
# https://ocdsdeploy.readthedocs.io/en/latest/how-to/update.html#using-a-testing-virtual-host

{% set extracontext %}
testing: False
{% endset %}
{{ apache('ocds-docs-' + pillar.environment + '.conf',
    name='ocds-docs-' + pillar.environment + '.conf',
    servername=pillar.subdomain + 'standard.open-contracting.org',
    extracontext=extracontext,
    https=pillar.https) }}

{% set extracontext %}
testing: True
{% endset %}
{{ apache('ocds-docs-' + pillar.environment + '.conf',
    name='ocds-docs-' + pillar.environment + '-testing.conf',
    servername='testing.' + pillar.testing_subdomain + 'standard.open-contracting.org',
    extracontext=extracontext,
    https=pillar.https) }}
