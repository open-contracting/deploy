{% from 'lib.sls' import apache %}

include:
  - apache

{% for name, entry in pillar.react_apps.items() %}

# A user might run multiple apps, so the user is not created here.
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set appdir = userdir + '/web/current' %}
{% set context = {'name': name, 'entry': entry, 'appdir': appdir} %}

{{ entry.git.url }}:
  git.latest:
    - name: {{ entry.git.url }}
    - user: {{ entry.user }}
    - force_fetch: True
    - force_reset: True
    - branch: {{ entry.git.branch }}
    - rev: {{ entry.git.branch }}
    - target: {{ directory }}
    - require:
      - pkg: git
      - user: {{ entry.user }}_user_exists

{{ appdir }}:
  file.symlink:
    - target: {{ directory }}
    - makedirs: True
    - runas: {{ entry.user }}
    - require:
      - git: {{ entry.git.url }}

{% if 'apache' in entry %}
{{ apache(entry.git.target, entry.apache, context=context) }}
{% endif %}

{{ userdir }}-nvm-install:
  cmd.run:
    - name: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    - runas: {{ entry.user }}
    - cwd: {{ userdir }}
    - require:
      - pkg: git

{% endfor %}
