Configuring PostgreSQL
======================

Specify version
---------------

The default version is 11.

To override the version, update the server's Pillar file:

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    version: 11

Enable public access
--------------------

By default, PostgreSQL only allows local connections (`see the template for the pg_bha.conf configuration file <https://github.com/open-contracting/deploy/blob/master/salt/postgres/files/pg_hba.conf>`__).

To enable public access, update the server's Pillar file:

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    public_access: True

Change default settings
-----------------------

#. Put your configuration file in the `salt/postgres/files <https://github.com/open-contracting/deploy/tree/master/salt/postgres/files>`__ directory.

#. Update the server's Pillar file. `Follow PostgreSQL's instructions <https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES>`__ for setting ``vm.nr_hugepages``:

  .. code-block:: yaml
    :emphasize-lines: 2

    postgres:
      configuration: kingfisher-process1
    vm:
      nr_hugepages: 1234

#. :doc:`Deploy<deploy>`

The configuration file should appear in ``/etc/postgresql/11/main/conf.d/`` on the server (for PostgreSQL version 11).

Set up replication
------------------

You will configure a main server and a replica server.

#. Create configuration files for each server as above. For reference, see the files for ``kingfisher-process`` and ``kingfisher-replica``.

#. Update the main server's Pillar file with the replica user's name and the replica's IP addresses:

   .. code-block:: yaml

      postgres:
        replica_user:
          username: example_username
        replica_ipv4:
          - 148.251.183.230
        replica_ipv6:
          - 2a01:4f8:211:de::2

#. Update the main server's private Pillar file in the ``pillar/private`` directory with the replica user's password.

   .. code-block:: yaml

      postgres:
        replica_user:
          password: example_password

#. Add the ``postgres.main`` state file to the main server's target in the ``salt/top.sls`` file.

#. :doc:`Deploy<deploy>` both servers

#. Transfer data and start replication.

   #. Connect to the replica server as the ``root`` user.

   #. Stop the PostgreSQL service and delete the main cluster's data.

      .. code-block:: bash

         service postgresql stop
         rm -rf /var/lib/postgresql/11/main # (for PostgreSQL version 11)

   #. Switch to the ``postgres`` user and transfer data.

      .. code-block:: bash

         su - postgres
         pg_basebackup -h ${main_host} -D /var/lib/postgresql/11/main -U ${replica_user} -v -P -Fp -Xs -R

      For example, for ``kingfisher-replica``:

      .. code-block:: bash

         pg_basebackup -h process1.kingfisher.open-contracting.org -D /var/lib/postgresql/11/main -U replica -v -P -Fp -Xs -R

   #. Switch to the ``root`` user and start the PostgreSQL service.

      .. code-block:: bash

         exit
         service postgresql start

   #. Double-check that the service started:

      .. code-block:: bash

         pg_lsclusters

#. It is recommended to enable replication slots:

   #. On the replica server:

      .. code-block:: bash

         echo "primary_slot_name = 'example_unique_identifier'" >> /var/lib/postgresql/11/main/recovery.conf
         service postgresql restart

   #. On the main server:

      .. code-block:: bash

         su - postgres
         psql -c "SELECT * FROM pg_create_physical_replication_slot('example_unique_identifier');"

#. (Optional) Enable automatic WAL archive restoration on the replica server:

   .. code-block:: bash

      echo "restore_command = 'cp /var/lib/postgresql/11/main/archive/%f %p'" >> /var/lib/postgresql/11/main/recovery.conf

Once you're done, the ``/var/lib/postgresql/11/main/recovery.conf`` file on the replica server should look something like this:

.. code-block:: none

  standby_mode = 'on'
  primary_conninfo = 'user=replica password=redacted host=process1.kingfisher.open-contracting.org port=5432 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
  restore_command = 'cp /var/lib/postgresql/11/main/archive/%f %p'
  primary_slot_name = 'replica1'
