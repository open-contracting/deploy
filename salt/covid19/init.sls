{% from 'lib.sls' import create_user, set_firewall %}

include:
    - python_apps

{{ set_firewall("PUBLIC_SSH") }}

{% set entry = pillar.python_apps.covid19admin %}

{{ create_user(entry.user, pillar.ssh.covid19admin) }}

