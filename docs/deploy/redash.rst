Redash tasks
============

Create a Redash server
----------------------

First, :doc:`create the new server<create_server>`, making sure to use the ``redash`` state file.

The ``redash`` state file installs, configures and sets up everything needed for redash to run. It installs its files in the ``/data/deploy/redash/`` directory.

.. note::

   Our redash installation is based on the `official setup repository<https://github.com/getredash/setup>`__.
   We have customised this setup adding the following features:
   * Updated Redash image
   * Updated Redis and added a healthcheck
   * Updated PostgreSQL and host the service outside of Docker
   * Proxy traffic through Apache for SSL termination

Initialize Redash
~~~~~~~~~~~~~~~~~

Before we can start the Redash application we need to import the Redash database.

#. If migrating from an old server.

   #. Connect to the old server. For example:

      .. code-block:: bash

         curl --silent --connect-timeout 1 ocp08.open-contracting.org:8255 || true
         ssh root@ocp08.open-contracting.org

   #. Dump the database. You might need to expose ports for the ``postgres`` service if ``postgres`` is still hosted in Docker.

      .. code-block:: bash

         pg_dump -h localhost -U postgres postgres -f redash.sql

   #. Disconnect from the old server:

      .. code-block:: bash

         exit

   #. Copy the database dump to your local machine. For example:

      .. code-block:: bash

         rsync -avz root@ocp08.open-contracting.org:~/redash.sql .

   #. Copy the database dump to the new server. For example:

      .. code-block:: bash

         rsync -avz redash.sql root@ocp14.open-contracting.org:~/

#. Connect to the new server. For example:

   .. code-block:: bash

      ssh root@ocp14.open-contracting.org

#. If the Redash database user is changing, update the .sql file. For example, to replace the previous database owner ``postgres`` with ``redash_user``:

   .. code-block:: bash

      sed -i 's/OWNER TO postgres/OWNER TO redash_user/g' redash.sql

#. Load the database dump using the PostgreSQL credentials:

   .. code-block:: bash

      sudo -u postgres psql redash_db -f redash.sql

#. Start the Redash application:

   .. code-block:: bash

      cd /data/deploy/redash/
      docker-compose up -d


Upgrade the Redash service
--------------------------

To upgrade Redash to a new version

#. Update the docker-compose configuration in the `salt deploy repository <https://github.com/open-contracting/deploy/blob/main/salt/docker_apps/files/redash.yaml>`__. Update the Docker image version to the latest release. There may be other changes required in new Redash releases, the `official release notes<https://github.com/getredash/redash/releases>`__ will have more details.

#. Deploy the Redash service, see :ref:`deploy documentation<generic-setup>`:

   .. code-block:: bash

      ./run.py 'redash' state.apply test=True

#. Connect to the server:

   .. code-block:: bash

      curl --silent --connect-timeout 1 ocp14.open-contracting.org:8255 || true
      ssh root@ocp14.open-contracting.org

#. Download required Docker container images:

   .. code-block:: bash

      docker-compose pull

#. Stop Redash services:

   .. code-block:: bash

      cd /data/deploy/redash/
      docker-compose stop server scheduler scheduled_worker adhoc_worker

#. Run Redash database migrations (if required):

   .. code-block:: bash

      docker-compose run --rm server manage db upgrade

#. Start the Redash application:

   .. code-block:: bash

      docker-compose up -d

Finally, check that the new version is running by viewing the `"System Status"<https://redash.open-contracting.org/admin/status>`__ page and reading the *Version*. You may need to log into Redash to access this page.

Troubleshoot
~~~~~~~~~~~~

To troubleshoot ``docker-compose`` commands, add the ``--verbose`` option.
