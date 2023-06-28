#!/usr/bin/env bash
# shellcheck disable=SC1083
cp /etc/apache2/md/domains/"$1"/pubcert.pem /etc/apache2/md/domains/"$1"/privkey.pem /etc/postgresql/{{ pillar.postgres.version }}/main/
# shellcheck disable=SC1083
chown postgres:postgres /etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem /etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem
systemctl restart postgresql
