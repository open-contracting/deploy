Configuring Postgres
====================

Change postgres version
-----------------------

The version of postgres that is installed defaults to version 11 but can be overwritten in your servers pillar file.

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    version: 11

Allow global connections
------------------------

By default postgres only listens for local connections, the template config can be found `here <https://github.com/open-contracting/deploy/blob/master/salt/postgres/configs/pg_hba.conf>`.

To allow public access set the following in pillar.

.. code-block:: yaml
  :emphasize-lines: 2

  postgres:
    public_access: True


Upload custom configuration
---------------------------

If you are customising any postgres settings these custom configs should be in the git repo.

#. Upload your configuration file `here <https://github.com/open-contracting/deploy/tree/master/salt/postgres/configs>`.

#. Point the ``pillar['postgres']['custom_configuration']`` parameter at your new config.

  .. code-block:: yaml
    :emphasize-lines: 2

    postgres:
      custom_configuration: salt://postgres/configs/kingfisher-process1-postgres.conf

#. Update with ``state.apply``, you will find your new config here ``/etc/postgresql/11/main/conf.d/`` (assuming the version is 11)



Setting up postgres replication
-------------------------------

For postgres replication you need to configure both a master server and a replica.

#. Upload custom configuration following the above guide.

   This configuration should enable wal_level replication.

   For reference, we've set this up on kingfisher-process1 and kingfisher-replica1.

#. Update master server pillar data with replica details

   .. code-block:: yaml
      postgres:
        replica_user:
          username: example_username
        replica_ips:
          - 198.51.100.0/32
          - 2001:db8::/128

   Put the replica user password in the ``pillar/private/`` repo.

   .. code-block:: yaml
      postgres:
        replica_user:
          password: example_password

#. Enable the ``postgres.replica_master`` state file on the master server

#. Apply changes

   The servers are now configured but we still need to copy the data over and start replication

#. Copy the data over and start replication

   .. code-block:: bash

     service postgresql stop
     rm -rf /var/lib/postgresql/11/main # (assuming the version is 11)
     su - postgres
     pg_basebackup -h ${master_server_hostname} -D /var/lib/postgresql/11/main -U ${replica_username} -v -P -Fp -Xs -R

     # For example on kingfisher-replica, I ran...
     pg_basebackup -h process1.kingfisher.open-contracting.org -D /var/lib/postgresql/11/main -U replica -v -P -Fp -Xs -R

     exit # go back to the root user

     service postgres start
     pg_lsclusters # Double check postgres has started

