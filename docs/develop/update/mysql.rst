Configure MySQL
===============

Specify the version
-------------------

The default version is 8.0.

To override the version, update the server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2

   mysql:
     version: '8.0'

Add users, groups and databases
-------------------------------

To configure the database for an application:

#. Add a user for the application, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/password-generator>`__ (uncheck *Symbols*) and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      mysql:
        users:
          USERNAME:
            password: "PASSWORD"

#. Create the database for the application and grant all privileges to the new user. Replace ``DATABASE`` and ``USERNAME``:

   .. code-block:: yaml
      :emphasize-lines: 6-7

      mysql:
        users:
          USERNAME:
            password: "PASSWORD"
        databases:
          DATABASE:
            user: USERNAME

#. Add the private Pillar file to the top file entry for the application.

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
        configuration: redmine

#. :doc:`Deploy the service<../../deploy/deploy>`

The configuration file will be in the ``/etc/mysql/conf.d`` directory on the server.

Set up backups
--------------

#. Configure the :doc:`AWS CLI<../awscli>`

#. Set ``mysql.backup.location`` in the server's Pillar file, for example:

   .. code-block:: yaml
      :emphasize-lines: 3

      mysql:
        backup:
          location: ocp-redmine-backups/database

#. :doc:`Deploy the service<../../deploy/deploy>`
