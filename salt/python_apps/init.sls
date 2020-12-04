{% if salt['pillar.get']('python_apps') %}
{% for entry in pillar.python_apps.values() %}

{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}

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

{{ directory }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ entry.user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ entry.git.url }}

{{ directory }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ entry.user }}
    - cwd: {{ directory }}
    - require:
      - virtualenv: {{ directory }}/.ve/
    - onchanges:
      - git: {{ entry.git.url }}

{% if entry.get('config') %}
{% for name, source in entry.config.items() %}
{{ userdir }}/.config/{{ name }}:
  file.managed:
    - source: {{ source }}
    - template: jinja
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists
{% endfor %}
{% endif %}

{% endfor %}
{% endif %}
