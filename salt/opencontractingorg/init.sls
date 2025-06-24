{% from 'lib.sls' import create_user %}

include:
  - apache.modules.rewrite # required by WordPress
  - php-fpm

{% set user = 'opencontractingorg' %}
{% set userdir = '/home/' + user %}

{{ create_user(user) }}

# Allow Apache to access. See wordpress.conf.include.
allow {{ userdir }} access:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/public_html:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists
