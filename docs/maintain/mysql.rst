Maintain MySQL
==============

Connect from a remote client
----------------------------

Forward your local port 3307 to the remote MySQL socket:

.. code-block:: bash

   ssh -N -L 3307:/var/run/mysqld/mysqld.sock <user>@ocp21.open-contracting.org

Connect to the remote MySQL database through your local port 3307. For example:

.. code-block:: bash

   mysql --host 127.0.0.1 --port 3307 --protocol TCP --user <user> -p <database>

Rotate a password without downtime
----------------------------------

Salt can be used to perform the rotation: update the ``password`` and ``password_hash`` (and a Docker app's ``DATABASE_URL``) in the private Pillar file, then deploy. Salt executes the ``ALTER USER`` SQL statement, updates ``DB_PASSWORD`` in a WordPress site's ``wp-config.php`` file, and updates ``DATABASE_URL`` in a Docker app's ``.env`` file.

This causes brief downtime, however. For no downtime, use dual passwords, so that both authenticate during rotation:

#. :ref:`Generate a hash<mysql-password-hash>` for the new `strong password <https://www.lastpass.com/features/password-generator>`__ (uncheck *Symbols*)
#. Add the new password on the server, while retaining the old password:

   .. code-block:: sql

      ALTER USER 'digitalbuying'@'172.16.0.0/12' IDENTIFIED WITH caching_sha2_password AS '<hash>' RETAIN CURRENT PASSWORD;

#. Update the ``password`` and ``password_hash`` (a Docker app's ``DATABASE_URL``) in the private Pillar file. To check that they agree:

   .. code-block:: shell-session

      $ uv run manage.py mysql-hash --check '<hash>'
      Password: <password>

#. :doc:`Deploy the server<../../deploy/deploy>`
#. Recreate Docker containers, as the ``deployer`` user:

   .. code-block:: bash

      cd /data/deploy/digitalbuying
      docker compose up -d

#. Discard the old password:

   .. code-block:: sql

      ALTER USER 'digitalbuying'@'172.16.0.0/12' DISCARD OLD PASSWORD;

.. _mysql-recover-backup:

Restore from backup
-------------------

mysqldump
~~~~~~~~~

#. Connect to the old server, and export the existing database. For example, to export ``corporate_wp``:

   .. code-block:: bash

      mysqldump corporate_wp | gzip > ~/corporate_wp.sql.gz

#. Copy the database dump to the new server. For example:

   .. code-block:: bash

      rsync -avz ~/corporate_wp.sql.gz root@ocp99.open-contracting.org:~/corporate_wp.sql.gz

#. Restore the database. For example:

   .. code-block:: bash

      gunzip ~/corporate_wp.sql.gz
      mysql corporate_wp < ~/corporate_wp.sql

#. If the database is a WordPress site's, :ref:`flush its caches<wordpress-migration>`.
