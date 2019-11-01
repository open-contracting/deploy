include:
  - ocds-docs-common

{% from 'lib.sls' import apache %}

# For information on the testing virtual host, see:
# https://ocdsdeploy.readthedocs.io/en/latest/how-to/update.html#using-a-testing-virtual-host

{% set extracontext %}
testing: False
{% endset %}
{{ apache('ocds-docs-staging.conf',
    name='ocds-docs-staging.conf',
    extracontext=extracontext,
    socket_name='',
    servername='staging.standard.open-contracting.org',
    serveraliases=[],
    https='yes') }}

{% set extracontext %}
testing: True
{% endset %}
{{ apache('ocds-docs-staging.conf',
    name='ocds-docs-staging-testing.conf',
    extracontext=extracontext,
    socket_name='',
    servername='testing.staging.standard.open-contracting.org',
    serveraliases=[],
    https='yes') }}

add-travis-key-for-ocds-docs-dev:
    ssh_auth.present:
        - user: ocds-docs
        - source: salt://private/ocds-docs/ssh_authorized_keys_from_travis
