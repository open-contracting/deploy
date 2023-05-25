Configure PostgreSQL
====================

Specify the version
-------------------

Set the version in the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2

   postgres:
     version: 11

.. _pg-public-access:

Enable public access
--------------------

By default, PostgreSQL only allows local connections (`see the template for the pg_bha.conf configuration file <https://github.com/open-contracting/deploy/blob/main/salt/postgres/files/pg_hba.conf>`__).

To enable public access, update the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2

   postgres:
     public_access: True

Add users, groups and databases
-------------------------------

To configure the database for an application:

#. Add a user for the application, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/password-generator>`__ (uncheck *Symbols*) and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      postgres:
        users:
          USERNAME:
            password: "PASSWORD"

#. Create the database for the application, revoke all schema privileges from the public role, and grant all schema privileges to the new user. Replace ``DATABASE`` and ``USERNAME``:

   .. code-block:: yaml
      :emphasize-lines: 6-7

      postgres:
        users:
          USERNAME:
            password: "PASSWORD"
        databases:
          DATABASE:
            user: USERNAME

#. If another application requires read-only access to the database, create a group and its privileges, replacing ``APPLICATION`` and ``SCHEMA``:

   .. code-block:: yaml
      :emphasize-lines: 2-3,10-12

      postgres:
        groups:
          - APPLICATION_read
        users:
          USERNAME:
            password: "PASSWORD"
        databases:
          DATABASE:
            user: USERNAME
            privileges:
              SCHEMA:
                - APPLICATION_read

   .. note::

      In most cases, the ``SCHEMA`` is ``public``, and the ``DATABASE``, ``APPLICATION`` and ``USERNAME`` are all the same.

#. Add the private Pillar file to the top file entry for the application.

.. note::

   To delete a PostgreSQL user, :ref:`follow these instructions<delete-postgresql-user>`.

.. _pg-add-configuration:

Configure PostgreSQL
--------------------

.. note::

   Even if you don't need to configure PostgreSQL, you must still set the following, in order for its SLS file to be automatically included:

   .. code-block:: yaml
      :emphasize-lines: 2

      postgres:
        configuration: False

#. Put your configuration file in the `salt/postgres/files/conf <https://github.com/open-contracting/deploy/tree/main/salt/postgres/files/conf>`__ directory. To use the base configuration, insert ``{% include 'postgres/files/conf/shared.include' %}`` at the top of the file.

#. Set ``postgres.configuration`` in the server's Pillar file:

   .. code-block:: yaml
      :emphasize-lines: 2

      postgres:
        configuration: kingfisher-process1

#. If you use the base configuration:

   -  Set ``storage`` to either ``ssd`` (solid-state drive, default) or ``hdd`` (hard disk drive).
   -  Set ``type`` to either ``oltp`` (online transaction processing, default) or ``dw`` (data warehouse).
   -  If you need more connections, set ``max_connections``.

   .. code-block:: yaml
      :emphasize-lines: 3-5

      postgres:
        configuration: registry
        storage: hdd
        type: oltp
        max_connections: 200

#. Set ``vm.nr_hugepages`` in the server's Pillar file, following `PostgreSQL's instructions <https://www.postgresql.org/docs/11/kernel-resources.html#LINUX-HUGE-PAGES>`__:

   .. code-block:: yaml
      :emphasize-lines: 2

      vm:
        nr_hugepages: 1234

#. :doc:`Deploy the service<../../deploy/deploy>`

The configuration file will be in the ``/etc/postgresql/11/main/conf.d/`` directory on the server (for PostgreSQL version 11).

.. _pg-setup-backups:

Set up backups
--------------

We use `pgBackRest <https://pgbackrest.org>`__ to create and manage offsite backups.
Salt will install and configure pgBackRest if ``postgres:backup`` is defined in Pillar data.

#. Create an S3 bucket and API Keys.

   .. note::

      pgBackRest supports any S3-compatible storage, including AWS and BackBlaze.

   If you are using AWS you will need to `create an S3 Bucket <https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html>`__ and `set up an IAM user <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html>`__.

   You can find an example IAM permissions policy in the `pgBackRest documentation <https://pgbackrest.org/user-guide.html#s3-support>`__.

#. Create pgbackrest pillar config.

   .. code-block:: yaml

      postgres:
        backup:
          # The configuration file for pgbackrest, this is loaded from ``salt/postgres/files/pgbackrest/``.
          configuration: kingfisher-process1
          # Unique identifier for backup configuration
          stanza: kingfisher
          # Concurrent processes for run pgbackrest with (backup speed vs CPU usage).
          # Optional.
          process_max: 4
          # Backup bucket region.
          s3_region: eu-central-1
          # Backup bucket name.
          s3_bucket: ocp-db-backup
          # s3 endpoint - `AWS S3 endpoints <https://docs.aws.amazon.com/general/latest/gr/s3.html>`__.
          s3_endpoint: s3.eu-west-1.amazonaws.com
          # API Access Key.
          s3_key: redacted
          # API Secret Key.
          s3_key_secret: redacted
          # Total full backups to store.
          total_full_backups: 4
          # Backup directory structure.
          repo_path=/kingfisher

   .. note::

      Incremental backups are taken daily (storing only the changes since the last full backup).
      Full backups are taken weekly, currently this runs on Sunday.
      So if ``total_full_backups`` is set to 4, backups will be stored for four weeks.

#. Create stanza.

   If this backup stanza has already been created you can skip this step.

   .. code-block:: bash

      su - postgres
      pgbackrest stanza-create --stanza=example

.. note::

   For information on using the pgbackrest tool to restore data, see :ref:`pg-recover-backup`.

Additional steps for replica servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When pgbackrest runs it will try backing up PostgreSQL data from a replica/standby server if any are configured. This is great because it gives us a backup of production while also reducing load during the backup.

.. note::

   You can find the :ref:`recovery steps here<pg-recover-replica>`.

#. Log into the main (replication source) server
#. Swap to the postgres user

   .. code-block:: bash

      su - postgres

#. Generate new SSH keys (if they do not already exist)

   .. code-block:: bash

      ssh-keygen -t rsa -b 4096

   This creates both a public (`~/.ssh/id_rsa.pub`) and private key (`~/.ssh/id_rsa`)

#. Add these new keys in deploy pillar

   #. Add the public key to `authorized_keys` on the replica server

      .. code-block:: yaml

         ssh:
           postgres:
             - ssh-rsa AAAB3N...

   #. Add the private key to `deploy-pillar-private <https://github.com/open-contracting/deploy-pillar-private>`__.

      .. code-block:: yaml

         postgres:
           ssh_key: |
             -----BEGIN RSA PRIVATE KEY-----
             ...

   #. :doc:`Deploy the service<../../deploy/deploy>`

.. _pg-setup-replication:

Set up replication
------------------

To configure a main server and a replica server:

#. Create configuration files for each server, :ref:`as above <pg-add-configuration>`. For reference, see the files for ``kingfisher-process1`` and ``kingfisher-replica1``.

#. Add the replica's IP addresses to the main server's Pillar file:

   .. code-block:: yaml

      postgres:
        replica_ipv4:
          - 148.251.183.230
        replica_ipv6:
          - 2a01:4f8:211:de::2

#. Add the ``replica`` user to the main server's private Pillar file:

   .. code-block:: yaml

      postgres:
        users:
          replica:
            password: example_password
            replication: True

   You will also need to pass this user to the replica server. This is used to populate the ``postgresql.conf`` file via pgbackrest.

   .. code-block:: yaml

      postgres:
        replication:
          username: replica
          password: example_password
          primary_slot_name: replica1

   .. note::

      If the ``replica`` user's password is changed, you must manually update the ``/var/lib/postgresql/11/main/postgresql.conf`` file on the replica server (for PostgreSQL version 11).

#. Add the ``postgres.main`` state file to the main server's target in the ``salt/top.sls`` file.

#. :doc:`Deploy<../../deploy/deploy>` both servers

#. Connect to the main server as the ``root`` user, and create a replication slot, replacing ``SLOT`` with the value of ``postgres:replication:primary_slot_name``.

   .. code-block:: bash

      su - postgres
      psql -c "SELECT * FROM pg_create_physical_replication_slot('SLOT');"

#. Transfer data and start replication.

   #. Connect to the replica server as the ``root`` user.

   #. Stop the PostgreSQL service and delete the main cluster's data.

      .. code-block:: bash

         systemctl stop postgresql
         rm -rf /var/lib/postgresql/11/main

   #. Switch to the ``postgres`` user and transfer PostgreSQL data.

      .. code-block:: bash

         su - postgres
         mkdir /var/lib/postgresql/11/main
         pgbackrest --stanza=example --type=standby restore

   #. Switch to the ``root`` user and start the PostgreSQL service.

      .. code-block:: bash

         exit
         systemctl start postgresql

   #. Double-check that the service started:

      .. code-block:: bash

         pg_lsclusters
