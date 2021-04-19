Redash tasks
============

Create a Redash server
----------------------

First, :doc:`create the new server<create_server>`, making sure to use the ``redash`` state file.

Update script
~~~~~~~~~~~~~

We `installed Redash <https://redash.io/help/open-source/setup#docker>`__ using its `setup script <https://github.com/getredash/setup>`__. However, we made a few changes to its ``setup.sh`` file:

#. Add a comment with a link to the version used of the setup script (to make it easier to compare against future scripts).
#. Comment out the ``install_docker`` function call. (The ``docker`` state file installs Docker, to keep system packages under Salt's management.)
#. Change the ``nginx`` service's `ports <https://docs.docker.com/compose/compose-file/#ports>`__ to ``9090:80`` instead of ``80:80``. (Apache is used to acquire SSL certificates.)
#. Expose the ``postgres`` service's ports as ``5432:5432`` (to make it easier to load a database dump).
#. Comment out the database creation (``docker-compose run``) and container startup (``docker-compose up``) commands (to be run after upgrade).

We also:

#. Remove unneeded packages ``apt-transport-https`` and ``curl``
#. Run ``shellcheck salt/redash/files/setup.sh``
#. Run ``shfmt -d -i 4 -sr salt/redash/files/setup.sh``
#. Apply the `Shell script style guide <https://ocp-software-handbook.readthedocs.io/en/latest/shell/index.html#shell-options>`__.

Before :ref:`running the script<run-redash-script>`, compare the ``setup.sh`` file in this repository to the latest version of the `setup script <https://github.com/getredash/setup>`__:

.. code-block:: bash

   curl -sS https://raw.githubusercontent.com/getredash/setup/master/setup.sh | diff -uw - salt/redash/files/setup.sh

.. _run-redash-script:

Run script
~~~~~~~~~~

#. If migrating from an old server, get its configuration settings and database dump.

   #. Connect to the old server. For example:

      .. code-block:: bash

         curl --silent --connect-timeout 1 redash.open-contracting.org:8255 || true
         ssh root@redash.open-contracting.org

   #. Copy the values of the ``REDASH_COOKIE_SECRET`` and ``REDASH_SECRET_KEY`` variables in the ``/opt/redash/env`` file on the old server:

      .. code-block:: bash

         cat /opt/redash/env

   #. Dump the database. You might need to expose ports for the ``postgres`` service.

      .. code-block:: bash

         pg_dump -h localhost -U postgres postgres -f redash.sql

   #. Disconnect from the old server:

      .. code-block:: bash

         exit

   #. Copy the database dump to your local machine. For example:

      .. code-block:: bash

         scp root@redash.open-contracting.org:~/redash.sql .

   #. Copy the database dump to the new server. For example:

      .. code-block:: bash

         scp redash.sql root@HOSTNAME:~/

   #. Edit the ``setup.sh`` file in this repository, setting the ``COOKIE_SECRET`` and ``SECRET_KEY`` variables to the values copied above.

#. Copy the ``setup.sh`` file in this repository to the new server. For example:

   .. code-block:: bash

      scp setup.sh root@HOSTNAME:~/

#. Connect to the new server. For example:

   .. code-block:: bash

      ssh root@HOSTNAME

#. Run the ``setup.sh`` file:

   .. code-block:: bash

      bash setup.sh

#. If migrating from an old server, restore the database dump and upgrade the database.

   #. Get the PostgreSQL credentials on the new server:

      .. code-block:: bash

         grep REDASH_DATABASE_URL /opt/redash/env

   #. Start the ``postgres`` service:

      .. code-block:: bash

         docker-compose up -d postgres

   #. Load the database dump using the PostgreSQL credentials:

      .. code-block:: bash

         psql -h localhost -U postgres postgres -f redash.sql

   #. Apply database migrations (starts services as needed):

      .. code-block:: bash

         docker-compose run --rm server manage db upgrade

#. If creating a new server from scratch, create the database:

   .. code-block:: bash

      docker-compose run --rm server create_db

#. Remove the ``ports`` variable from the ``/opt/redash/docker-compose.yml`` file:

   .. code-block:: bash

      sed -i '/postgresql/{n;N;d}' /opt/redash/docker-compose.yml

#. Edit the ``opt/redash/env`` file to enable the `permissions <https://github.com/getredash/redash/pull/1113>`__ feature:

   .. code-block:: bash

      echo 'REDASH_FEATURE_SHOW_PERMISSIONS_CONTROL=true' >> /opt/redash/env

#. Edit the ``opt/redash/env`` file to `configure the mail server <https://redash.io/help/open-source/setup#Mail-Configuration>`__.

#. Restart Redash:

   .. code-block:: bash

       docker-compose stop
       docker-compose up -d

#. Test the email configuration using the `Password Reset <https://redash.open-contracting.org/forgot>`__ feature.

.. _upgrade-redash:

Upgrade the Redash service
--------------------------

To upgrade Redash without creating a new server, see the `official documentation <https://redash.io/help/open-source/admin-guide/how-to-upgrade>`__ and `release list <https://github.com/getredash/redash/releases>`__.

-  If instructed, edit the ``docker-compose.yml`` file in the ``/opt/redash`` directory.
-  If missing, add the ``-d`` option to any ``docker-compose up`` commands from Redash's documentation, to run containers in the background.

To compare the ``docker-compose.yml`` file to that in the `getredash/setup <https://github.com/getredash/setup/blob/master/data/docker-compose.yml>`__ repository, run:

.. code-block:: bash

   curl -sS https://raw.githubusercontent.com/getredash/setup/master/data/docker-compose.yml | diff -u - /opt/redash/docker-compose.yml

.. note::

   The ``getredash/setup`` repository might not be up-to-date.

Finally, check that the new version is running by `accessing Redash <https://redash.open-contracting.org>`__, clicking your name, and reading the *Version*.

Troubleshoot
~~~~~~~~~~~~

To troubleshoot ``docker-compose`` commands, add the ``--verbose`` option.
