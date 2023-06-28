#!/bin/sh
if [ "$1" = "installed" ] && [ "$2" = "{{ pillar.postgres.ssl.servername }}" ]; then
  # shellcheck disable=SC1083
  cp /etc/apache2/md/domains/"$2"/pubcert.pem /etc/apache2/md/domains/"$2"/privkey.pem /etc/postgresql/{{ pillar.postgres.version }}/main/
  # shellcheck disable=SC1083
  chown postgres:postgres /etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem /etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem
  systemctl reload postgresql.service
fi
