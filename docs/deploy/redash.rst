Redash tasks
============

Create to a Redash server
-------------------------

#. If migrating from an old server:

   #. Connect to the old server. For example:

      .. code-block:: bash

         ssh root@redash.open-contracting.org

   #. Copy the values of the ``REDASH_COOKIE_SECRET`` and ``REDASH_SECRET_KEY`` variables in the ``/opt/redash/env`` file on the old server:

      .. code-block:: bash

         cat /opt/redash/env

   #. Dump the database:

      .. code-block:: bash

         TODO > redash.sql

   #. Disconnect from the old server:

      .. code-block:: bash

         exit

   #. Copy the database dump to your local machine. For example:

      .. code-block:: bash

         scp root@redash.open-contracting.org:~/redash.sql .

   #. Copy the database dump to the new server. For example:

      .. code-block:: bash

         scp redash.sql root@host:~/

   #. Edit the ``setup-redash.sh`` file in this repository:

      #. Set the ``COOKIE_SECRET`` and ``SECRET_KEY`` variables to the values copied above.
      #. Comment out the line: ``sudo docker-compose run --rm server create_db``

#. Copy the ``setup-redash.sh`` file in this repository to the new server. For example:

   .. code-block:: bash

      scp setup-redash.sh root@host:~/

#. Connect to the new server. For example:

   .. code-block:: bash

      ssh root@host

#. Run the ``setup-redash.sh`` file:

   .. code-block:: bash

      bash setup-redash.sh

#. If migrating from an old server:

   #. Get the PostgreSQL credentials on the new server:

      .. code-block:: bash

         grep REDASH_DATABASE_URL /opt/redash/env

   #. Load the database dump using the PostgreSQL credentials:

      .. code-block:: bash

         psql -h localhost -U postgres postgres -f redash.sql

   #. TODO:

      .. code-block:: bash

         docker-compose run --rm server create_db

#. Remove the ``ports`` variable from the ``/opt/redash/docker-compose.yml`` file:

   .. code-block:: bash

      sed -i '/postgresql/{n;N;d}' /opt/redash/docker-compose.yml

#. :ref:`Restart Redash<restart-redash>`.

Configure Redash
----------------

#. Enable the `permissions <https://github.com/getredash/redash/pull/1113>`__ feature:

   .. code-block:: bash

      echo 'REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL=true' >> /opt/redash/env

#. Edit the ``opt/redash/env`` file to `configure mail servers <https://redash.io/help/open-source/setup#Mail-Configuration>`__.

#. :ref:`Restart Redash<restart-redash>`.

#. Test the email configuration using the `Password Reset <https://redash.open-contracting.org/forgot>`__ feature.

.. _restart-redash:

Upgrade Redash
--------------

`See official documentation <https://redash.io/help/open-source/admin-guide/how-to-upgrade>`__.

Restart Redash
--------------

.. code-block:: bash

    cd /opt/redash
    docker-compose stop
    docker-compose up -d
