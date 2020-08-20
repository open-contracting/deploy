Configure PostgreSQL
====================

Specify version
---------------

The default version is 11.

To override the version, update the server's pillar file:

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    version: 11

Enable public access
--------------------

By default, PostgreSQL only listens for local connections (`see the template for the pg_bha.conf configuration file <https://github.com/open-contracting/deploy/blob/master/salt/postgres/configs/pg_hba.conf>`__).

To enable public access, update the server's pillar file:

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    public_access: True

Change default settings
-----------------------

#. Put your configuration file in the `salt/postgres/configs <https://github.com/open-contracting/deploy/tree/master/salt/postgres/configs>`__ directory.

#. Update the server's pillar file:

  .. code-block:: yaml
    :emphasize-lines: 2

    postgres:
      custom_configuration: salt://postgres/configs/kingfisher-process1-postgres.conf

#. :doc:`Deploy<deploy>`

The configuration file should appear in ``/etc/postgresql/11/main/conf.d/`` on the server (for PostgreSQL version 11).

Set up replication
------------------

You will configure a master server and a replica server.

#. Create configuration files for each server as above, setting ``wal_level = replica``. For reference, see the files for ``kingfisher-process1`` and ``kingfisher-replica1``.

#. Update the master server's pillar file with the replica user's name and the replica's IP addresses:

   .. code-block:: yaml

      postgres:
        replica_user:
          username: example_username
        replica_ips:
          - 198.51.100.0/32
          - 2001:db8::/128

#. Update the master server's private pillar file in the ``pillar/private`` directory with the replica user's password.

   .. code-block:: yaml

      postgres:
        replica_user:
          password: example_password

#. Add the ``postgres.replica_master`` state file to the master server's target in the ``salt/top.sls`` file.

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
         pg_basebackup -h ${master_server_hostname} -D /var/lib/postgresql/11/main -U ${replica_username} -v -P -Fp -Xs -R

      For example, for ``kingfisher-replica``:

      .. code-block:: bash

         pg_basebackup -h process1.kingfisher.open-contracting.org -D /var/lib/postgresql/11/main -U replica -v -P -Fp -Xs -R

   #. Switch to the ``root`` user and start the PostgreSQL service.

      .. code-block:: bash

         exit
         service postgres start

   #. Double-check that the service started:

      .. code-block:: bash

         pg_lsclusters
