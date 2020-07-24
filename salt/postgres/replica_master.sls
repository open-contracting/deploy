#
# Configure postgres replication master specific settings.
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

