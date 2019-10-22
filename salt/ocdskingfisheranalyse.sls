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

ocdskingfisheranalyse-pipinstall:
  pip.installed:
    - upgrade: True
    - user: {{ user }}
    - requirements: salt://ocdskingfisheranalyse/pipinstall.txt

ocdskingfisheranalyse-pip-path:
  file.append:
    - name: /home/{{ user }}/.bashrc
    - text: "export PATH=\"/home/{{ user }}/.local/bin/:$PATH\""

