include:
  - ocds-docs-common

{% from 'lib.sls' import apache %}

# For information on the testing virtual host, see:
# https://ocdsdeploy.readthedocs.io/en/latest/how-to/update.html#using-a-testing-virtual-host

{% set extracontext %}
testing: False
{% endset %}
{{ apache('ocds-docs-live.conf',
    name='ocds-docs-live.conf',
    extracontext=extracontext,
    socket_name='',
    servername='standard.open-contracting.org',
    serveraliases=[],
    https='force') }}

{% set extracontext %}
testing: True
{% endset %}
{{ apache('ocds-docs-live.conf',
    name='ocds-docs-live-testing.conf',
    extracontext=extracontext,
    socket_name='',
    servername='testing.live.standard.open-contracting.org',
    serveraliases=[],
    https='force') }}

https://github.com/open-contracting/standard-legacy-staticsites.git:
  git.latest:
    - rev: master
    - target: /home/ocds-docs/web/legacy/
    - user: ocds-docs
    - force_fetch: True
    - force_reset: True

/home/ocds-docs/web/robots.txt:
  file.managed:
    - source: salt://ocds-docs/robots_live.txt
    - user: ocds-docs
