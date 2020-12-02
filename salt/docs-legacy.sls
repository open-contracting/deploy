# This sets up redirects and an archived opendatacomparison static site for ocds.open-contracting.org,
# which has been replaced by standard.open-contracting.org

{% from 'lib.sls' import createuser, apache %}

{% set user = 'opencontracting' %}
{{ createuser(user) }}

https://github.com/open-contracting/opendatacomparison-archive.git:
  git.latest:
    - rev: live
    - target: /home/{{ user }}/opendatacomparison-archive/
    - user: {{ user }}
    - require:
      - pkg: git
    - watch_in:
      - service: apache2

{{ apache('docs-legacy', name='ocds-legacy', servername='ocds.open-contracting.org') }}
