{% from 'lib.sls' import create_user %}

include:
  - python_apps

{% set entry = pillar.python_apps.collect_generic %}
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

{{ create_user(entry.user, authorized_keys=salt['pillar.get']('ssh:collect_generic', [])) }}

# It is insufficient to give Apache permission to /home/collect_generic/data only.
allow Apache access to {{ userdir }}:
  file.directory:
    - name: {{ userdir }}
    - mode: 755
    - require:
      - user: {{ user }}_user_exists

{{ userdir }}/data:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - mode: 755
    - require:
      - user: {{ entry.user }}_user_exists

{{ userdir }}/logs:
  file.directory:
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - require:
      - user: {{ entry.user }}_user_exists
