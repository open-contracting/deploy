include:
  - kingfisher.process

# This should be the same as process.sls, where the user is created.
{% set user = 'ocdskfp' %}
{% set userdir = '/home/' + user %}

{% set summarize_giturl = 'https://github.com/open-contracting/kingfisher-summarize.git' %}
{% set summarize_dir = userdir + '/ocdskingfisherviews' %}

####################
# Git repositories
####################

{{ summarize_giturl }}{{ summarize_dir }}:
  git.latest:
    - name: {{ summarize_giturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ summarize_dir }}
    - require:
      - pkg: git
      - user: {{ user }}_user_exists

####################
# Python packages
####################

{{ summarize_dir }}/.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - pip_pkgs:
      - pip-tools
    - require:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

{{ summarize_dir }}-requirements:
  cmd.run:
    - name: . .ve/bin/activate; pip-sync -q
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - virtualenv: {{ summarize_dir }}/.ve/
    - onchanges:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

####################
# Configuration
####################

{{ userdir }}/.config/kingfisher-summarize/logging.json:
  file.managed:
    - source: salt://kingfisher/summarize/files/logging.json
    - user: {{ user }}
    - group: {{ user }}
    - makedirs: True
    - require:
      - user: {{ user }}_user_exists

{{ summarize_dir }}/.env:
  file.managed:
    - source: salt://kingfisher/summarize/files/.env
    - user: {{ user }}
    - group: {{ user }}
    - mode: 400
    - require:
      - git: {{ summarize_giturl }}{{ summarize_dir }}

####################
# App installation
####################

{{ summarize_dir }}-install:
  cmd.run:
    - name: . .ve/bin/activate; ./manage.py install
    - runas: {{ user }}
    - cwd: {{ summarize_dir }}
    - require:
      - cmd: {{ summarize_dir }}-requirements
      - file: {{ userdir }}/.pgpass
      - file: {{ summarize_dir }}/.env
      - postgres_database: db_ocdskingfisherprocess
    - onchanges:
      - git: {{ summarize_giturl }}{{ summarize_dir }}
