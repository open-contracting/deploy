Configure MySQL
===============

Specify the version
-------------------

The `default version <https://endoflife.date/mysql>`__ is 8.0 (`LTS <https://endoflife.date/mysql>`__).

To override the version, update the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2

   mysql:
     version: '8.0'

.. _mysql-password-hash:

Generate a password hash
------------------------

``manage.py mysql-hash`` reads a password from standard input, and writes its hash to standard output:

.. code-block:: bash

   uv run manage.py mysql-hash

.. note::

   ``password_hash`` is used instead of ``password`` until `saltstack/salt#66859 <https://github.com/saltstack/salt/issues/66859>`__ is fixed. Salt can't verify a ``password`` unless the ``mysql_native_password`` plugin is used, whereas it can verify a ``password_hash`` always.

Add users, groups and databases
-------------------------------

To configure the database for an application:

#. Add a user for the application, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/features/password-generator>`__ (uncheck *Symbols*), ``HASH`` with :ref:`its hash<mysql-password-hash>`, and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      mysql:
        users:
          USERNAME:
            password: PASSWORD
            password_hash: "HASH"
            host: "192.0.2.1"

   By default, ``host`` is set to ``localhost``.

#. Create the database for the application and grant all privileges to the new user, in a public Pillar file, replacing ``DATABASE`` and ``USERNAME``:

   .. code-block:: yaml

      mysql:
        databases:
          DATABASE:
            user: USERNAME
            host: "192.0.2.1"

#. Add the Pillar files to the top file entry for the application.

Configure MySQL
---------------

.. note::

   Even if you don't need to configure MySQL, you must still set the following, in order for its SLS file to be automatically included:

   .. code-block:: yaml
      :emphasize-lines: 2

      mysql:
        configuration: False

#. Put your configuration file in the `salt/mysql/files/conf <https://github.com/open-contracting/deploy/tree/main/salt/mysql/files/conf>`__ directory.
#. Set ``mysql.configuration`` in the server's Pillar file:

   .. code-block:: yaml
      :emphasize-lines: 2

      mysql:
        configuration: myconfig

#. :doc:`Deploy the server<../../deploy/deploy>`

The configuration file will be in the ``/etc/mysql/conf.d`` directory on the server.

.. _mysql-backups:

Set up backups
--------------

#. Create and configure an :ref:`S3 backup bucket<amazon-s3-bucket>`
#. Configure the :doc:`AWS CLI<awscli>`
#. In the server's Pillar file, set ``mysql.backup.location`` to a bucket and prefix, for example:

   .. code-block:: yaml
      :emphasize-lines: 2-3

      mysql:
        backup:
          location: ocp-coalition-backup/database

#. :doc:`Deploy the server<../../deploy/deploy>`
