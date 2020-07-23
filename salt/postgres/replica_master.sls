#
# Configure postgres replication master specific settings.
# 
# To set up a replica client:
# * Update the postgres configs enabling replication and allowing connections from the replica server IP.
# * Run the following backup command.
#   * pg_basebackup -h grains.fqdn -D /var/lib/postgresql/ pillar["postgres"]["version"] /main -U replica -v -P -Fp -Xs -R
#


/var/lib/postgresql/{{ pillar["postgres"]["version"] }}/main/archive/:
  file.directory:
    - user: postgres
    - group: postgres
    - mode: 700
    - makedirs: True
    - recurse:
      - user
      - group

replica_user:
  postgres_user.present:
    - name: {{ pillar['postgres']['replica_user']['username'] }}
    - password: md5{MD5OF({{ pillar['postgres']['replica_user']['password'] }})
    - encrypted: True
    - login: True
    - replication: True

