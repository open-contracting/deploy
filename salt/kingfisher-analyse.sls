{% from 'lib.sls' import createuser %}

# Set up the things people need to be able to make use of the powerful server for analysis work

kingfisher-analyse-prerequisites:
  pkg.installed:
    - pkgs:
      - jq
      - unrar
      - unzip

{% set user = 'analysis' %}
{{ createuser(user, authorized_keys=pillar.ssh.kingfisher) }}

kingfisher-analyse-pipinstall:
  pip.installed:
    - upgrade: True
    - user: {{ user }}
    - requirements: salt://kingfisher/pipinstall.txt
    - bin_env: /usr/bin/pip3

kingfisher-analyse-pip-path:
  file.append:
    - name: /home/{{ user }}/.bashrc
    - text: "export PATH=\"/home/{{ user }}/.local/bin/:$PATH\""
