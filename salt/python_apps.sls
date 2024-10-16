{% from 'lib.sls' import virtualenv %}

include:
  - python.virtualenv

# Inspired by the Apache formula, which loops over sites to configure. See example in readme.
# https://github.com/saltstack-formulas/apache-formula
# https://github.com/saltstack-formulas/apache-formula/blob/master/apache/config/register_site.sls
{% for name, entry in pillar.python_apps|items %}

# A user might run multiple apps, so the user is not created here.
{% set userdir = '/home/' + entry.user %}
{% set directory = userdir + '/' + entry.git.target %}
{% set context = {'name': name, 'entry': entry, 'appdir': directory} %}

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

# Note: {{ directory }}-requirements will run if git changed (not only if requirements changed).
# https://github.com/open-contracting/deploy/issues/146
{{ virtualenv(directory, entry.user, {'git': entry.git.url}, {'git': entry.git.url}) }}

{% for filename, source in entry.config|items %}
{{ userdir }}/.config/{{ filename }}:
  file.managed:
    - source: {{ source }}
    - template: jinja
    - user: {{ entry.user }}
    - group: {{ entry.user }}
    - makedirs: True
    - require:
      - user: {{ entry.user }}_user_exists
{% endfor %}{# config #}

{% endfor %}
