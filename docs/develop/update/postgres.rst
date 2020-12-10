Configure PostgreSQL
====================

Specify the version
-------------------

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
    public_access: true

Add your configuration
----------------------

#. Put your configuration file in the `salt/postgres/files <https://github.com/open-contracting/deploy/tree/master/salt/postgres/files>`__ directory.

#. Update the server's Pillar file. `Follow PostgreSQL's instructions <https://www.postgresql.org/docs/current/kernel-resources.html#LINUX-HUGE-PAGES>`__ for setting ``vm.nr_hugepages``:

  .. code-block:: yaml
    :emphasize-lines: 2

    postgres:
      configuration: kingfisher-process1
    vm:
      nr_hugepages: 1234

#. :doc:`Deploy<deploy>`

The configuration file will be in the ``/etc/postgresql/11/main/conf.d/`` directory on the server (for PostgreSQL version 11).

Set up replication
------------------

To configure a main server and a replica server:

#. Create configuration files for each server, as above. For reference, see the files for ``kingfisher-process1`` and ``kingfisher-replica1``.

#. Update the main server's Pillar file with the replica user's name and the replica's IP addresses:

   .. code-block:: yaml

      postgres:
        replica_user:
          username: example_username
        replica_ipv4:
          - 148.251.183.230
        replica_ipv6:
          - 2a01:4f8:211:de::2

#. Update the main server's private Pillar file with the replica user's password:

   .. code-block:: yaml

      postgres:
        replica_user:
          password: example_password

   .. note::

      If the replica user's name or password are changed, you must manually update the ``/var/lib/postgresql/11/main/recovery.conf`` file on the replica server (for PostgreSQL version 11).

#. Add the ``postgres.main`` state file to the main server's target in the ``salt/top.sls`` file.

#. :doc:`Deploy<deploy>` both servers

#. Connect to the main server as the ``root`` user, and create a replication slot, replacing ``SLOT``:

   .. code-block:: bash

      su - postgres
      psql -c "SELECT * FROM pg_create_physical_replication_slot('SLOT');"

#. Transfer data and start replication (all commands are for PostgreSQL version 11).

   #. Connect to the replica server as the ``root`` user.

   #. Stop the PostgreSQL service and delete the main cluster's data.

      .. code-block:: bash

         service postgresql stop
         rm -rf /var/lib/postgresql/11/main

   #. Switch to the ``postgres`` user and transfer data:

      .. code-block:: bash

         su - postgres
         pg_basebackup -h ${main_host} -U ${replica_user} --slot={slot} \
             -D /var/lib/postgresql/11/main --write-recovery-conf --verbose --progress

      For example, for ``kingfisher-replica``:

      .. code-block:: bash

         pg_basebackup -h process1.kingfisher.open-contracting.org -U replica --slot=replica1 \
             -D /var/lib/postgresql/11/main --write-recovery-conf --verbose --progress

      .. note::

         The `--write-recovery-conf option <https://www.postgresql.org/docs/11/app-pgbasebackup.html>`__ writes a ``/var/lib/postgresql/11/main/recovery.conf`` file, with ``standby_mode``, ``primary_conninfo`` and ``primary_slot_name`` lines.

   #. Enable automatic WAL archive restoration on the replica server:

      .. code-block:: bash

         echo "restore_command = 'cp /var/lib/postgresql/11/main/archive/%f %p'" >> /var/lib/postgresql/11/main/recovery.conf

   #. Switch to the ``root`` user and start the PostgreSQL service.

      .. code-block:: bash

         exit
         service postgresql start

   #. Double-check that the service started:

      .. code-block:: bash

         pg_lsclusters

Once you're done, the ``/var/lib/postgresql/11/main/recovery.conf`` file on the replica server will look like:

.. code-block:: none

  standby_mode = 'on'
  primary_conninfo = 'user=replica password=redacted host=process1.kingfisher.open-contracting.org port=5432 sslmode=prefer sslcompression=0 gssencmode=prefer krbsrvname=postgres target_session_attrs=any'
  primary_slot_name = 'replica1'
  restore_command = 'cp /var/lib/postgresql/11/main/archive/%f %p'
