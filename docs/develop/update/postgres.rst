Configure PostgreSQL
====================

Specify the version
-------------------

Set the version in the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2

   postgres:
     version: 15

.. _pg-public-access:

Enable public access
--------------------

By default, PostgreSQL only allows local connections (`see the template for the pg_bha.conf configuration file <https://github.com/open-contracting/deploy/blob/main/salt/postgres/files/pg_hba.conf>`__).

To enable public access, update the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 3

   postgres:
     version: 15
     public_access: True

Add users, groups, databases and schemas
----------------------------------------

To configure the database for an application:

#. Add a user for the application, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/features/password-generator>`__ (uncheck *Symbols*) and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      postgres:
        users:
          USERNAME:
            password: "PASSWORD"

#. Create the database for the application, revoke all schema privileges from the public role, and grant all schema privileges to the new user. Replace ``DATABASE`` and ``USERNAME``:

   .. code-block:: yaml
      :emphasize-lines: 5-7

      postgres:
        users:
          USERNAME:
            password: "PASSWORD"
        databases:
          DATABASE:
            user: USERNAME

#. Create a schema, if needed by the application. Replace ``SCHEMA`` and ``OWNER``, and change ``TYPE`` to ``user`` or ``group``:

   .. code-block:: yaml
      :emphasize-lines: 8-11

      postgres:
        users:
          USERNAME:
            password: "PASSWORD"
        databases:
          DATABASE:
            user: USERNAME
            schemas:
              SCHEMA:
                name: OWNER
                type: TYPE

   .. note::

      If the owner needs to be a group, create the group, replacing ``NAME``:

      .. code-block:: yaml
         :emphasize-lines: 2-3

         postgres:
           groups:
             - NAME

#. If another application needs read-only access to the database, create a group and its privileges, replacing ``APPLICATION`` and ``SCHEMA``:

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
                APPLICATION_read:

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

#. Put your configuration template in the `salt/postgres/files/conf <https://github.com/open-contracting/deploy/tree/main/salt/postgres/files/conf>`__ directory. In most cases, you should use the ``shared`` configuration template.

#. Set ``postgres.configuration`` in the server's Pillar file:

   .. code-block:: yaml
      :emphasize-lines: 2-6

      postgres:
        configuration:
          name: kingfisher-main1
          source: shared
          context:
            mykey: myvalue

   The keys of the ``context`` mapping are made available as variables in the configuration template.

#. If you use the ``shared`` configuration template, under the ``context`` mapping:

   -  If you need more or fewer than 100 connections, set ``max_connections`` (100, default).
   -  Set ``storage`` to either ``ssd`` (solid-state drive, default) or ``hdd`` (hard disk drive).
   -  Set ``type`` to either ``oltp`` (online transaction processing, default) or ``dw`` (data warehouse).
   -  Set ``content`` to add content to the configuration file.

   .. code-block:: yaml
      :emphasize-lines: 3-5

      postgres:
        configuration:
          name: registry
          source: shared
          context:
            max_connections: 300
            storage: hdd
            type: oltp
            content: |
              max_wal_size = 10GB

#. Set ``vm.nr_hugepages`` in the server's Pillar file, following `PostgreSQL's instructions <https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES>`__:

   .. code-block:: yaml
      :emphasize-lines: 2

      vm:
        nr_hugepages: 1234

#. :doc:`Deploy the service<../../deploy/deploy>`

The configuration file will be in the ``/etc/postgresql/11/main/conf.d/`` directory on the server (for PostgreSQL version 11).

Use CA certificates
-------------------

.. note::

   Only do this if a third-party service requires CA certificates.

#. Set the hostname for PostgreSQL:

   .. code-block:: yaml
      :emphasize-lines: 2-3

      postgres:
        ssl:
          servername: postgres.kingfisher.open-contracting.org

#. :ref:`Configure the mod_md Apache module<mod_md-configure>` to copy the SSL certificates to PostgreSQL's directory:

   .. code-block:: yaml

      apache:
        public_access: True
        modules:
          mod_md:
            MDMessageCmd: /opt/postgresql-certificates.sh

#. :ref:`Acquire the SSL certificates<ssl-certificates>`.

.. _pg-setup-backups:

Set up full backups
-------------------

.. seealso::

   :ref:`pg-recover-backup`

`pgBackRest <https://pgbackrest.org>`__ is used to create and manage offsite backups.

#. Create and configure an :ref:`S3 backup bucket<aws-s3-bucket>`
#. :ref:`Create an IAM backup policy and user<aws-iam-backup-policy>`
#. Create a ``*.conf`` configuration file in the ``salt/postgres/files/pgbackrest/`` directory. In most cases, you should use the ``shared`` configuration.
#. Install and configure pgBackRest. Add to the server's Pillar file, for example:

   .. code-block:: yaml

      postgres:
        configuration:
          ...
          context:
            content: |
              ### pgBackRest
              # https://pgbackrest.org/user-guide.html#quickstart/configure-archiving

              # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-WAL-LEVEL
              wal_level = logical

              # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-ARCHIVE-MODE
              archive_mode = on

              # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-ARCHIVE-COMMAND
              # https://pgbackrest.org/user-guide.html#async-archiving/async-archive-push
              archive_command = 'pgbackrest --stanza=kingfisher-2023 archive-push %p'

              # https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-MAX-WAL-SENDERS
              max_wal_senders = 4
        backup:
          type: pgbackrest
          configuration: shared
          # The rest are specific to your configuration file.
          stanza: kingfisher
          retention_full: 4
          repo_path: /kingfisher
          process_max: 4
          cron: |
              MAILTO=root
              # Daily incremental backup
              15 05 * * 0-2,4-6 postgres pgbackrest backup --stanza=kingfisher-2023
              # Weekly full backup
              15 05 * * 3 postgres pgbackrest backup --stanza=kingfisher-2023 --type=full 2>&1 | grep -v "unable to remove file.*We encountered an internal error\. Please try again\.\|expire command encountered 1 error.s., check the log file for details"

   .. note::

      ``max_wal_senders`` is set to 4, because `pgBackRest <https://pgbackrest.org/user-guide.html#quickstart/configure-archiving>`__ and `annotated.conf <https://github.com/jberkus/annotated.conf/blob/master/postgresql.10.simple.conf>`__ recommend a value of twice the number of *potential future* replicas. This value counts towards ``max_connections``.

   .. note::

      The ``grep -v`` command means ``root`` receives mail if there is more than 1 error. To check whether the error message in the ``grep`` command is up-to-date:

      -  `unable to remove file '%s' <https://github.com/pgbackrest/pgbackrest/blob/4adf6eed09da3f0819abef813c5a44deb9c91487/src/storage/storage.intern.h#L43>`__
      -  `expire command encountered %u error(s), check the log file for details <https://github.com/pgbackrest/pgbackrest/blob/4adf6eed09da3f0819abef813c5a44deb9c91487/src/command/expire/expire.c#L1078>`__
      -  "We encountered an internal error. Please try again." is from AWS.

   .. seealso::

      -  `Configure Cluster Stanza <https://pgbackrest.org/user-guide.html#quickstart/configure-stanza>`__
      -  `Configuration Reference <https://pgbackrest.org/configuration.html>`__

#. Add, in a private Pillar file:

   .. code-block:: yaml

      postgres:
        backup:
          s3_bucket: ocp-db-backup
          s3_region: eu-central-1
          s3_endpoint: s3.eu-west-1.amazonaws.com
          s3_key: ...
          s3_key_secret: ...

   .. seealso::

      `Amazon S3 regular endpoints <https://docs.aws.amazon.com/general/latest/gr/s3.html>`__

#. Create the stanza, if it doesn't exist yet:

   .. code-block:: bash

      su -u postgres pgbackrest stanza-create --stanza=example

   .. seealso::

      `Create the Stanza <https://pgbackrest.org/user-guide.html#quickstart/create-stanza>`__

Set up database-specific backups
--------------------------------

.. note::

   Only use database-specific backups if :ref:`full backups<pg-setup-backups>` would backup many GBs of unwanted data.

#. Create and configure an :ref:`S3 backup bucket<aws-s3-bucket>`
#. Configure the :doc:`AWS CLI<awscli>`
#. In the server's Pillar file, set ``postgres.backup.location`` to a bucket and prefix, ``postgres.backup.databases`` to a list of databases, and ``postgres.backup.type`` to "script", for example:

   .. code-block:: yaml

      postgres:
        backup:
          type: script
          location: ocp-registry-backup/database
          databases:
            - spoonbill_web
            - pelican_frontend

#. :doc:`Deploy the service<../../deploy/deploy>`

Additional steps for replica servers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When pgBackRest runs it will try backing up PostgreSQL data from a replica/standby server if any are configured. This is great because it gives us a backup of production while also reducing load during the backup.

.. note::

   You can find the :ref:`recovery steps here<pg-recover-replica>`.

#. :doc:`SSH<../../use/ssh>` into the main server as the ``postgres`` user.
#. Generate an SSH key pair, if one doesn't already exist:

   .. code-block:: bash

      ssh-keygen -t rsa -b 4096

#. Add the public SSH key to the ``ssh.postgres`` list in the **replica** server's Pillar file:

   .. code-block:: yaml

      ssh:
        postgres:
          - ssh-rsa AAAB3N...

#. Set ``postgres.ssh_key`` in the **main** server's private Pillar file to the private SSH key:

   .. code-block:: yaml

      postgres:
        ssh_key: |
          -----BEGIN RSA PRIVATE KEY-----
          ...

#. :doc:`Deploy the main server and replica server<../../deploy/deploy>`

.. _pg-setup-replication:

Set up replication
------------------

To configure a main server and a replica server:

#. Create configuration files for each server, :ref:`as above <pg-add-configuration>`. For reference, see the files for ``kingfisher-main1`` and ``kingfisher-replica1``.

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

   You will also need to pass this user to the replica server. This is used to populate the ``postgresql.conf`` file via pgBackRest.

   .. code-block:: yaml

      postgres:
        replication:
          username: replica
          password: example_password
          primary_slot_name: replica1

   .. note::

      If the ``replica`` user's password is changed, you must manually update the ``/var/lib/postgresql/11/main/postgresql.conf`` file on the replica server (for PostgreSQL version 11).

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
