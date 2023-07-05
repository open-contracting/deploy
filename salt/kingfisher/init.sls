{% from 'lib.sls' import create_user %}

{% for user, authorized_keys in pillar.users.items() %}
{{ create_user(user, authorized_keys=authorized_keys) }}
{% endfor %}

useful commands for data support:
  pkg.installed:
    - pkgs:
      - jq
      - ripgrep
      - unrar

pip:
  pkg.installed:
    - name: python3-pip
  pip.installed:
    - name: pip
    - upgrade: True
    - require:
      - pkg: pip

useful packages for data support:
  pip.installed:
    - names:
      - flattentool
      - ocdskit
    - upgrade: True
    - require:
      - pip: pip
