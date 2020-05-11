{% from 'lib.sls' import createuser %}

root_kingfisher:
  ssh_auth.present:
    - user: root
    - source: salt://private/authorized_keys/root_to_add_kingfisher

/etc/motd:
  file.managed:
    - source: salt://system/ocdskingfisher_motd
