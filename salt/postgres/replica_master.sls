# Configure postgres replication master specific settings.

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

/home/sysadmin-tools/bin/:
  file.directory:
    - makedirs: True

/home/sysadmin-tools/bin/delete-after-x-days.sh:
  file.managed:
    - mode: 755
    - source: salt://lib/delete-after-x-days.sh

# Using file.append rather than the salt cron module.
# Because system crons are easier to find if they are all stored in /etc.
/etc/cron.d/replica_monitoring:
  file.append:
    - text: |
        MAILTO=root
        15 10 * * * postgres /home/sysadmin-tools/bin/delete-after-x-days.sh 7 /var/lib/postgresql/{{ pg_version }}/main/archive/

replica_user:
  postgres_user.present:
    - name: {{ pillar['postgres']['replica_user']['username'] }}
    - password: {{ pillar['postgres']['replica_user']['password'] }}
    - encrypted: True
    - login: True
    - replication: True

