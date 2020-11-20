{{ configurefirewall("PUBLICSSHSERVER") }}
{{ configurefirewall("PUBLICHTTPSERVER") }}
{{ configurefirewall("PUBLICHTTPSSERVER") }}

root_covid19:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_covid19
