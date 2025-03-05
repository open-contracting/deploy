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

.. seealso::

   :ref:`pg-control-access`

Each service should have a service account. To configure the database for an application:

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

.. _pg-add-configuration:

Configure PostgreSQL
--------------------

.. note::

   Even if you don't need to configure PostgreSQL, you must still set the following, in order for its SLS file to be automatically included:

   .. code-block:: yaml
      :emphasize-lines: 2

      postgres:
        configuration: False

#. Put your configuration template in the `salt/postgres/files/conf <https://github.com/open-contracting/deploy/tree/main/salt/postgres/files/conf>`__ directory. In most cases, you should use the existing ``shared`` configuration template, instead.
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

#. :doc:`Deploy the server<../../deploy/deploy>`

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
#. Install and configure pgBackRest. Add to the server's Pillar file, for example, if using both the ``shared`` PostgreSQL and pgBackRest configurations:

   .. code-block:: yaml

      postgres:
        configuration:
          name: kingfisher-main1
          source: shared
        backup:
          type: pgbackrest
          configuration: shared
          stanza: kingfisher-2023
          repo_path: /kingfisher

   .. seealso::

      -  `Configure Cluster Stanza <https://pgbackrest.org/user-guide.html#quickstart/configure-stanza>`__
      -  `Configuration Reference <https://pgbackrest.org/configuration.html>`__

#. Add, in a private Pillar file:

   .. code-block:: yaml

      postgres:
        backup:
          s3_bucket: ocp-db-backup
          s3_key: ...
          s3_key_secret: ...
          s3_endpoint: s3.eu-central-1.amazonaws.com
          s3_region: eu-central-1

   .. seealso::

      `Amazon S3 endpoints <https://docs.aws.amazon.com/general/latest/gr/s3.html>`__

#. Create the stanza, if it doesn't exist yet:

   .. code-block:: bash

      su -u postgres pgbackrest stanza-create --stanza=example

   .. seealso::

      `Create the Stanza <https://pgbackrest.org/user-guide.html#quickstart/create-stanza>`__

Configure the replica, if any
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. seealso::

   :ref:`pg-recover-replica`

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

.. seealso::

   `Backup from a Standby <https://pgbackrest.org/user-guide.html#standby-backup>`__

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

#. :doc:`Deploy the server<../../deploy/deploy>`

.. _pg-setup-replication:

Set up replication
------------------

To configure a main server and a replica server:

#. Create pgBackRest configuration files for each server. Example: `kingfisher-main1 <https://github.com/open-contracting/deploy/blob/059f43cddd9558688ab13a208244ff61d8570ff9/salt/postgres/files/pgbackrest/kingfisher-main1.conf>`__, `kingfisher-replica1 <https://github.com/open-contracting/deploy/blob/059f43cddd9558688ab13a208244ff61d8570ff9/salt/postgres/files/pgbackrest/kingfisher-replica1.conf>`__
#. :ref:`Enable PostgreSQL synchronous commits in the main server's Pillar file<pg-add-configuration>`:

   .. code-block:: yaml

        # https://www.postgresql.org/docs/current/runtime-config-wal.html#GUC-SYNCHRONOUS-COMMIT
        synchronous_commit = local

        # https://www.postgresql.org/docs/current/runtime-config-replication.html#GUC-SYNCHRONOUS-STANDBY-NAMES
        synchronous_standby_names = 'example01'

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
