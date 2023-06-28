#!/usr/bin/env bash
if [ -d /etc/apache2/md/staging/"$1" ]; then
  DIRECTORY=staging
else
  DIRECTORY=domains
fi
# shellcheck disable=SC1083
cp /etc/apache2/md/"$DIRECTORY"/"$1"/pubcert.pem /etc/apache2/md/"$DIRECTORY"/"$1"/privkey.pem /etc/postgresql/{{ pillar.postgres.version }}/main/
# shellcheck disable=SC1083
chown postgres:postgres /etc/postgresql/{{ pillar.postgres.version }}/main/pubcert.pem /etc/postgresql/{{ pillar.postgres.version }}/main/privkey.pem
systemctl reload postgresql.service
