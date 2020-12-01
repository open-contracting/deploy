{% from 'lib.sls' import apache, configurefirewall %}

{{ configurefirewall("PUBLIC_HTTP") }}
{{ configurefirewall("PUBLIC_HTTPS") }}
{{ configurefirewall("PUBLIC_SSH") }}

root_covid19:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_covid19
