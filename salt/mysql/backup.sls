{% from 'lib.sls' import set_config %}

include:
  - aws

{{ set_config("aws-settings.local", "S3_DATABASE_BACKUP_BUCKET", pillar.mysql.backup.location ) }}

/home/sysadmin-tools/bin/mysql-backup-to-s3.sh:
  file.managed:
    - source: salt://files/mysql-backup-to-s3.sh
    - mode: 750
    - require:
      - file: /home/sysadmin-tools/bin
      - sls: aws

/etc/cron.d/mysql_backup:
  file.managed:
    - contents: |
        MAILTO=root
        45 04 * * * root /home/sysadmin-tools/bin/mysql-backup-to-s3.sh
    - require:
      - file: /home/sysadmin-tools/bin/mysql-backup-to-s3.sh

# Default to blank if there is no root password.
/home/sysadmin-tools/mysql-defaults.cnf:
  file.managed:
    - contents: |
       [client]
       user = root
       password = {{ salt['pillar.get']('mysql:users:root:password', '') }}
    - mode: 600
    - require:
      - file: /home/sysadmin-tools/bin
