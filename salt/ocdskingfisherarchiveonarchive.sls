{% from 'lib.sls' import createuser %}

{% set user = 'archive' %}
{{ createuser(user, auth_keys_files=['kingfisher']) }}

/home/{{ user }}/data:
  file.directory:
    - user: {{ user }}
    - group: {{ user }}
    - require:
      - user: {{ user }}_user_exists

