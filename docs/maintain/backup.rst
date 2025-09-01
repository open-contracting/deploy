Testing backups
===============

Every six months, check that:

1. Backup automation is enabled and running.
1. Backup files are valid and usable.

General instructions
--------------------

Document any exceptions, exclusions or deviations from standard procedure.

-  Coverage

   -  Were new sites or apps added since the last test, requiring database or file backups?

-  Database backups

   -  Are the backup files complete?
   -  Do other databases or database services need backups?

-  File backups

   -  Are the backup files complete and up-to-date?
   -  Do other files or directories need backups?

-  Disk snapshots

   -  Are disk snapshots enabled?

-  Storage

   -  Are backup locations documented?
   -  Are backup credentials accessible to admins?
   -  Are backup files off-site?
   -  Are there the correct number of backup files?
   -  Do backup files cover the retention period?
   -  Do backup files expire?
   -  DO backup files have the correct names?

-  Recovery

   -  Is the recovery process documented?
   -  Is there enough disk space to uncompress backup files?

Retrieve AWS S3 backup files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These steps are repeated for each test below. Each bucket has separate credentials.

From a server:

-  Add the credentials to the environment:

   .. code-block:: bash

      . /home/sysadmin-tools/aws-settings.local
      export AWS_ACCESS_KEY_ID
      export AWS_SECRET_ACCESS_KEY
      export AWS_DEFAULT_REGION

-  Change to a temporary directory in the current working directory, in which to store backup files:

   .. code-block:: bash

      cd $(mktemp -dp . backup-testing-XXXX)

-  After testing, remove the temporary directory:

   .. code-block:: bash

      cd ..
      rm -rf backup-testing-*

Database backups
----------------

PostgreSQL (pgBackRest)
~~~~~~~~~~~~~~~~~~~~~~~

.. seealso:: :ref:`PostgreSQL full backups<pg-setup-backups>`

Check that servers running PostgreSQL use pgBackRest to backup all databases to S3, taking weekly full backups and daily incremental backups, with 4-week retention.

Servers
  -  ``kingfisher-main``
Test
  .. code-block:: bash

     su - postgres
     pgbackrest info
Recovery
  See :ref:`pg-recover-backup`

PostgreSQL (pg_dump)
~~~~~~~~~~~~~~~~~~~~

.. seealso:: :ref:`PostgreSQL database-specific backups<pg-setup-backups-pg_dump>`

If PostgreSQL contains large databases with transient data, we backup individual databases instead of all databases. The databases are selected in the ``/home/sysadmin-tools/aws-settings.local`` file.

Backup script
  `postgres-backup-to-s3.sh <https://github.com/open-contracting/deploy/blob/main/salt/postgres/files/postgres-backup-to-s3.sh>`__ creates backup files using ``pg_dump`` and uploads them to S3.
Servers
  -  ``registry`` (the ``data_registry`` and ``spoonbill_web`` databases)
Test
  .. code-block:: bash

     # Complete the steps in "Retrieve AWS S3 backup files" above.
     aws s3 ls s3://$S3_DATABASE_BACKUP_BUCKET/
     aws s3 cp s3://$S3_SITE_BACKUP_BUCKET/example.tar .

     tar --force-local -xvf example.tar
Recovery
  See :ref:`pg-recover-backup-universal`

MySQL
~~~~~

.. seealso:: :ref:`MySQL backups<mysql-backups>`

Backup script
  `mysql-backup-to-s3.sh <https://github.com/open-contracting/deploy/blob/main/salt/mysql/files/mysql-backup-to-s3.sh>`__ creates backup files using ``mysqldump`` and uploads them to S3.
Servers
  -  ``cms``
Test
  .. code-block:: bash

     # Complete the steps in "Retrieve AWS S3 backup files" above.
     aws s3 ls s3://$S3_DATABASE_BACKUP_BUCKET/
     aws s3 cp s3://$S3_DATABASE_BACKUP_BUCKET/example.sql.gz .

     zcat example.sql.gz | tail
     # Confirm "Dump completed on ..." is reported on the last line.

File backups
------------

.. seealso:: :doc:`../develop/update/backup`

Backup script
  `site-backup-to-s3.sh <https://github.com/open-contracting/deploy/blob/main/salt/backup/files/site-backup-to-s3.sh>`__ creates backup files using ``tar`` and uploads them to S3.
Servers
  -  ``cms``
  -  ``dream-bi``
Test
  .. code-block:: bash

     aws s3 ls s3://$S3_SITE_BACKUP_BUCKET/
     aws s3 cp s3://$S3_SITE_BACKUP_BUCKET/example.tar.gz .

     tar -xzvf example.tar.gz
     # Review the backup files and compare the names, sizes and timestamps to the actual files.

.. _backups-snapshots:

Disk snapshots
--------------

Hetzner Dedicated and Microsoft Azure have no disk snapshots to test.

Linode
~~~~~~

Check that disk snapshots are :doc:`configured<../deploy/create_server>`.

.. note::

   The `Linode Backup Service <https://techdocs.akamai.com/cloud-computing/docs/getting-started-with-the-linode-backup-service>`__ creates snapshots daily, retaining one daily and two weekly snapshots.

Hetzner Cloud
~~~~~~~~~~~~~

Check that disk snapshots are :doc:`configured<../deploy/create_server>`.

.. note::

   Hetzner Backups creates snapshots daily, retaining seven daily snapshots.
