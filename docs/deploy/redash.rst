Redash tasks
============

Create a Redash server
----------------------

#. Configure :doc:`PostgreSQL<../develop/update/postgres>` and :doc:`Docker apps<../develop/update/docker>` in the server's Pillar file
#. :doc:`Create the new server<create_server>`
#. :doc:`Configure an external firewall<../develop/update/firewall>`, opening SSH, ICMP, HTTP and HTTPS.

.. note::

   Our Docker Compose file is based on the `official setup repository <https://github.com/getredash/setup>`__, with these changes:

   -  Use Apache for SSL termination
   -  Update the PostgreSQL version and run it on the host
   -  Update the Redis version and add a health check
   -  Update the Redash version

Dump the old server's database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. :doc:`SSH<../use/ssh>` into the old server as the ``root`` user.
#. Create the database dump. (If PostgreSQL is running in Docker, you might need to expose its ports first.) For example:

   .. code-block:: bash

      pg_dump -h localhost -U postgres -f redash.sql postgres

#. Change the database user to ``redash``, if necessary. For example:

   .. code-block:: bash

      sed -i 's/OWNER TO postgres/OWNER TO redash/g' redash.sql

#. Disconnect from the old server:

   .. code-block:: bash

      exit

#. Copy the database dump to your local machine. For example:

   .. code-block:: bash

      rsync -avz root@ocp08.open-contracting.org:~/redash.sql .

#. Copy the database dump to the new server. For example:

   .. code-block:: bash

      rsync -avz redash.sql root@ocp14.open-contracting.org:~/

Load the new server's database
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. :doc:`SSH<../use/ssh>` into the new server as the ``root`` user.
#. Load the database dump into the ``redash`` database:

   .. code-block:: bash

      sudo -i -u postgres psql -f redash.sql redash

#. Change to the non-root user and Redash directory:

   .. code-block:: bash

      su - deployer
      cd /data/deploy/redash

#. Start the containers:

      docker compose up -d

Upgrade the Redash service
--------------------------

#. Update the ``image`` in the `Docker Compose file <https://github.com/open-contracting/deploy/blob/main/salt/docker_apps/files/redash.yaml>`__ to the latest tag. Read the `release notes <https://github.com/getredash/redash/releases>`__ for any other updates to make.

#. :doc:`Deploy the service<deploy>`.
#. :doc:`SSH<../use/ssh>` into ``redash.open-contracting.org`` as the ``root`` user.
#. Change to the non-root user and Redash directory:

   .. code-block:: bash

      su - deployer
      cd /data/deploy/redash

#. Pull the images:

   .. code-block:: bash

      docker compose pull

#. Stop the Redash containers:

   .. code-block:: bash

      docker compose stop server scheduler scheduled_worker adhoc_worker worker

#. Run database migrations, if required:

   .. code-block:: bash

      docker compose run --rm server manage db upgrade

#. Start the Redash containers:

   .. code-block:: bash

      docker compose up -d

#. Check that the new version is running by viewing the `System Status <https://redash.open-contracting.org/admin/status>`__ page and reading the *Version*. You may need to log in to Redash to access this page.
