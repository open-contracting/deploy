{% from 'lib.sls' import create_user %}
{% from 'docker_apps/init.sls' import docker_apps_directory %}

include:
  - docker_apps

{% set entry = pillar.docker_apps.qlikauth %}
{% set directory = docker_apps_directory + entry.target %}

{% set user = 'dreambi' %}
{% set userdir = '/home/' + user %}

{{ create_user(user, authorized_keys=pillar.ssh.dreambi) }}

useful commands for RBC Group:
  pkg.installed:
    - pkgs:
      - mc
      - telnet

# Allow Apache to access.
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

# RBC Group doesn't deploy by pulling git.

# {{ userdir }}/dream:
#   git.latest:
#     - name: https://github.com/open-contracting/bi.dream.gov.ua
#     - user: root
#     - force_fetch: True
#     - force_reset: True
#     - branch: build
#     - rev: build
#     - target: {{ userdir }}/dream
#     - require:
#       - pkg: git

# {{ userdir }}/mdcp:
#   git.latest:
#     - name: https://github.com/open-contracting/bi.dream.gov.ua-mdcp
#     - user: root
#     - force_fetch: True
#     - force_reset: True
#     - branch: build
#     - rev: build
#     - target: {{ userdir }}/mdcp
#     - require:
#       - pkg: git

{% for stem, contents in pillar.docker_apps.qlikauth.certs|items %}
{{ directory }}/certs/{{ stem }}.pem:
  file.managed:
    - contents: "{{ contents }}"
    - user: {{ pillar.docker.user }}
    - group: {{ pillar.docker.user }}
    - makedirs: True
    - require:
      - user: {{ pillar.docker.user }}_user_exists
{% endfor %}
