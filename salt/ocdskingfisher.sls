{% from 'lib.sls' import createuser %}

/etc/motd:
  file.managed:
    - source: salt://system/ocdskingfisher_motd


