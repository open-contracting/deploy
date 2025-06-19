Backup Testing
==============

The below processes describe the steps taken to ensure the integrity of Open Contracting Partnerships backups. There are two main properties that this process checks: firstly, are backups enabled and running; secondly, are backups valid and usable.

All backups are tested six monthly.

General Instructions for all servers
------------------------------------
With each of the following items, there can be (and are) exceptions, it is important that any exclusions and deviations from standard procedure are documented.

* For each Linode server, are full disk backups enabled?
* File backups:
  * Have any new sites / apps added since the last test are backed up?
  * Do the backups store the files we think they do?
    * Compare file timestamps between the backup and live files.
  * Are there any other files or directories that need backing up?
* Database backups:
  * Are the database backups complete?
    * MySQL backups report "Dump Complete" when successful.
  * there any other databases or database services that need backing up?
* Backup storage:
  * Are backups stored offsite?
  * Are backups accessible when the server is offline?
    * Where are credentials stored?
    * Is the backup location documented?
  * Is there the correct number of backups?
  * Are backups appropriately named?
  * Do backups cover our required timeframe?
  * Are retention periods set to prevent files being stored forever?
* Recovery:
  * Is the recovery process documented?
  * Does the system have enough disk space to uncompress a backup?

PostgreSQL - pgBackRest
-----------------------
Servers running PostgreSQL should use **pgBackRest** to take regular backups of all databases. Backups are managed by pgBackRest and stored in S3.

We are taking weekly "full" backups and daily incremental. Backups are kept for 4 weeks.

Servers:
* Kingfisher

Testing Process:

.. code-block:: bash

   su - postgres
   pgbackrest info

Recovery:

pgBackRest recovery steps are recorded in the :ref:`maintenance Documentation<pg-recover-backup>`.

PostgreSQL - pg_dump
--------------------
Backups are taken by `postgres-backup-to-s3.sh<https://github.com/open-contracting/deploy/blob/main/salt/postgres/files/postgres-backup-to-s3.sh>`__ using pg_dump and copied to S3. This tool is for PostgreSQL servers where we cannot backup all databases; such as Registry, pg_dump is used to take backups at a database level. Databases to backup are explicitly set in the aws-settings.local file.

Servers:
* Registry - Backups only the "data_registry" and "spoonbill_web" databases are backed up.

Testing Process:

.. code-block:: bash

   # Fetch database backups (See S3 Backup Retrieval).
   aws s3 ls s3://$S3_DATABASE_BACKUP_BUCKET/
   aws s3 cp s3://$S3_SITE_BACKUP_BUCKET/example.tar .
   
   tar --force-local -xvf example.tar

Recovery:

pg_dump recovery steps are recorded in the :ref:`maintenance Documentation<pg-recover-backup-universal>`.


MySQL
-----
Backups are taken by `mysql-backup-to-s3.sh<https://github.com/open-contracting/deploy/blob/main/salt/mysql/files/mysql-backup-to-s3.sh>`__ using mysqldump and copied to S3.

Servers
* CMS

Testing Process:

.. code-block:: bash

   # Fetch database backups (See S3 Backup Retrieval).
   aws s3 ls s3://$S3_DATABASE_BACKUP_BUCKET/
   aws s3 cp s3://$S3_DATABASE_BACKUP_BUCKET/example.sql.gz .
   
   zcat example.sql.gz | tail
   # Confirm "dump complete" is reported on the last line.


Site File Backups
-----------------
Backups are taken by `site-backup-to-s3.sh<https://github.com/open-contracting/deploy/blob/main/salt/backup/files/site-backup-to-s3.sh>`__ using tar and copied to S3.

Testing Process

.. code-block:: bash

   # Fetch database backups (See S3 Backup Retrieval).
   aws s3 ls s3://$S3_SITE_BACKUP_BUCKET/
   aws s3 cp s3://$S3_SITE_BACKUP_BUCKET/example.tar.gz .
   
   tar -xzvf example.tar.gz
   # Review site files and compare them to live.


Linode
------
Each Linode server should have the Linode backup service enabled. Linode backups provide the following: Three backup slacks are executed and rotated automatically: A daily backup, a 2-7 day old backup and a 8-14 day old backup.

Hetzner
-------
Hetzner servers do not have file backups. Currently these are not needed, all site data should be stored directly in GitHub.

Hetzner Cloud
-------------
Hetzner cloud servers should have the Hetzner disk snapshot service enabled. For every server there are seven slots for backups. Disk snapshots are taken daily. 

Azure
-----
Currently, there are no servers in Azure which require backup testing.
