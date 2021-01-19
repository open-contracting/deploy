{% from 'lib.sls' import apache, create_user %}


include:
  - apache

curl:
  pkg.installed

{% for name, entry in pillar.reactjs_apps.items() %}

{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set build_dir = userdir + '/web/current' %}
{% set context = {'name': name, 'entry': entry, 'appdir': build_dir} %}

{{ create_user(entry.user, pillar.ssh.covid19) }}

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

{{ userdir }}-link-source-code:
  cmd.run:
    - name: rm {{ build_dir }}; ln -s {{ directory }} {{ build_dir }}
    - runas: {{ entry.user }}
    - cwd: {{ userdir }}
    - require:
      - {{ entry.git.url }}

{% if 'apache' in entry %}
{{ apache(entry.git.target, entry.apache, context=context) }}
{% endif %}{# apache #}

{{ userdir }}-nvm-install:
  cmd.run:
    - name: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    - runas: {{ entry.user }}
    - cwd: {{ userdir }}
    - require:
      - pkg: git
      - pkg: curl

{% endfor %}
