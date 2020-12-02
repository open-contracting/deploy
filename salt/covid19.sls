{% from 'lib.sls' import set_firewall %}

{{ set_firewall("PUBLIC_HTTP") }}
{{ set_firewall("PUBLIC_HTTPS") }}
{{ set_firewall("PUBLIC_SSH") }}

root_covid19:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_covid19
