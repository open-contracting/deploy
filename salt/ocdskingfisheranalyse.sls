{% from 'lib.sls' import createuser %}

# Set up the things people need to be able to make use of the powerful server for analysis work

ocdskingfisheranalyse-prerequisites  :
  pkg.installed:
    - pkgs:
      - unrar
      - jq
      - git

{% set user = 'analysis' %}
{{ createuser(user, auth_keys_files=['kingfisher']) }}

{% set userdir = '/home/' + user %}


######### Flatten Tool

{% set flattentoolgiturl = 'https://github.com/OpenDataServices/flatten-tool.git' %}
{% set flattentooldir = userdir + '/flatten-tool/' %}

{{ flattentoolgiturl }}{{ flattentooldir }}:
  git.latest:
    - name: {{ flattentoolgiturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ flattentooldir }}
    - require:
      - ocdskingfisheranalyse-prerequisites

{{ flattentooldir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - cwd: {{ flattentooldir }}
    - requirements: {{ flattentooldir }}requirements.txt
    - require:
      - git: {{ flattentoolgiturl }}{{ flattentooldir }}

########## OCDSKit


{% set ocdskitgiturl = 'https://github.com/open-contracting/ocdskit.git' %}
{% set ocdskitdir = userdir + '/ocdskit/' %}

{{ ocdskitgiturl }}{{ ocdskitdir }}:
  git.latest:
    - name: {{ ocdskitgiturl }}
    - user: {{ user }}
    - force_fetch: True
    - force_reset: True
    - branch: master
    - rev: master
    - target: {{ ocdskitdir }}
    - require:
      - ocdskingfisheranalyse-prerequisites

{{ ocdskitdir }}.ve/:
  virtualenv.managed:
    - python: /usr/bin/python3
    - user: {{ user }}
    - system_site_packages: False
    - cwd: {{ ocdskitdir }}
    - require:
      - git: {{ ocdskitgiturl }}{{ ocdskitdir }}

{{ ocdskitdir }}install:
  cmd.run:
    - name: . .ve/bin/activate; pip3 install -e .
    - runas: {{ user }}
    - cwd: {{ ocdskitdir }}
    - require:
      - {{ ocdskitdir }}.ve/
