#
# Configure postgres replication master specific settings.
# 

# Default to postgres version 11, if not defined in pillar.
{% set pg_version = salt['pillar.get']('postgres:version', '11') %}

/var/lib/postgresql/{{ pg_version }}/main/archive/:
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

