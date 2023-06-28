#!/usr/bin/env bash
cp /etc/apache2/md/domains/"$1"/pubcert.pem /etc/apache2/md/domains/"$1"/privkey.pem /etc/postgresql/{{ pillar.postgres.version }}/main/
chown postgres:postgres /etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem /etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem
systemctl restart postgresql
