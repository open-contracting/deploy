Data support
============

Create a data support main server
---------------------------------

Dependencies
~~~~~~~~~~~~

Tinyproxy
  #. Update the allowed IP addresses in the ``pillar/tinyproxy.sls`` file.
  #. Deploy the ``docs`` service, when ready.
Replica, if applicable
  #. Update the allowed IP addresses and hostname in the ``pillar/kingfisher_replica.sls`` file.
  #. Deploy the ``kingfisher-replica`` service, when ready.

Dependents
~~~~~~~~~~

#. Notify RBC Group of the new domain name for the new PostgreSQL server.

Update Salt and halt jobs
~~~~~~~~~~~~~~~~~~~~~~~~~

#. Check that ``docker.uid`` in the server's Pillar file matches the entry in the ``/etc/passwd`` file for the ``docker.user`` (``deployer``).
#. Change ``cron.present`` to ``cron.absent`` in the ``salt/pelican/backend/init.sls`` file.
#. Comment out the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the old server and the new server<../deploy>`.
#. On the old server:

   #. Delete the ``/etc/cron.d/postgres_backups`` file.
   #. ``docker compose down`` all containers.

#. Check that no crawls are running at https://collect.kingfisher.open-contracting.org/jobs.

   If a crawl is running, job owners can `cancel jobs <https://collect.data.open-contracting.org/jobs>`__.

#. Check that no messages are enqueued at https://rabbitmq.kingfisher.open-contracting.org.

   If a job is running in Kingfisher Process, job owners can `cancel jobs <https://kingfisher-process.readthedocs.io/en/latest/cli.html#cancelcollection>`__.

.. _kingfisher-pelican-docker-migration:

Docker apps
~~~~~~~~~~~

#. Run migrations for :doc:`Docker apps<../docker>` as the ``deployer`` user:

   .. code-block:: bash

      su - deployer

      cd /data/deploy/kingfisher-process/
      docker compose run --rm --name django-migrate cron python manage.py migrate

      cd /data/deploy/pelican-frontend/
      docker compose run --rm --name django-migrate web python manage.py migrate

#. :doc:`Pull new images and start new containers for each Docker app<../docker>`.

Kingfisher Collect
~~~~~~~~~~~~~~~~~~

Once DNS has propagated, :ref:`update-spiders`.

Set up incremental updates
^^^^^^^^^^^^^^^^^^^^^^^^^^

Incremental updates are implemented with cron jobs that crawl data from a specific spider incrementally and periodically.
We typically do this to feed Business Intelligence tools.

To add a new incremental update:

#. Define the spider to use. For selecting one, keep in mind, that, ideally:

   #. We should retrieve new data only. The spider should support date filters, the more granular the better.
   #. We should retrieve data fast. The spider should be the fasted available for the publisher.
   #. We should avoid unnecessary processing steps. The spider should return compiled releases.

#. Add an entry in the ``pillar/kingfisher_main.sls`` file, under ``python_apps/kingfisher_collect/crawls``:

   #. Set ``identifier`` to the publisher's name in upper case and _ separated. E.g. DOMINICAN_REPUBLIC
   #. Set ``spider`` to the spider name. E.g. dominican_republic_api
   #. Set ``crawl_time`` to the current date. E.g. '2025-05-06'
   #. Optionally, set ``spider_arguments`` to any required `spider arguments <https://kingfisher-collect.readthedocs.io/en/latest/spiders.html#spider-arguments>`__. For example, if the spider returns releases and not compiled releases, add ``-a compile_releases=true``.
   #. Optionally, set ``cardinal`` to True, if the the data is to feed a tool that uses cardinal.
   #. Optionally, set a ``users`` list, if additional database users needs read access to the database
   #. Optionally, set ``day`` to 1, to run the cron job monthly and not daily, if the spider takes long time to be completed, for example.

#. Optionally, before deploying the changes, do a first manual crawl if the crawl takes a long time to be finished (e.g. weeks), by running the `commands <https://github.com/open-contracting/deploy/blob/main/salt/kingfisher/collect/files/cron.sh>`__ accordingly.

#. :doc:`Deploy the new server<../deploy>`.

Copy incremental data
^^^^^^^^^^^^^^^^^^^^^

#. :doc:`SSH<../../use/ssh>` into the new server as the ``incremental`` user:

   #. Generate an SSH key pair:

      .. code-block:: bash

         ssh-keygen -t rsa -b 4096 -C "incremental"

   #. Get the public SSH key:

      .. code-block:: bash

         cat ~/.ssh/id_rsa.pub

#. Add the public SSH key to the ``ssh.incremental`` list in the ``pillar/kingfisher_main.sls`` file:

   .. code-block:: yaml

      ssh:
        incremental:
          - ssh-rsa AAAB3N...

#. Change ``cron.present`` to ``cron.absent`` in the ``salt/kingfisher/collect/incremental.sls`` file.
#. :doc:`Deploy the old server and the new server<../deploy>`.
#. :doc:`SSH<../../use/ssh>` into the old server as the ``incremental`` user:

   #. Stop any processes started by the cron jobs.
   #. Dump the ``kingfisher_collect`` database:

      .. code-block:: bash

         pg_dump -U kingfisher_collect -h localhost -f kingfisher_collect.sql kingfisher_collect

#. :doc:`SSH<../../use/ssh>` into the new server as the ``incremental`` user.

   #. Copy the database dump from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:~/kingfisher_collect.sql .

   #. Load the database dump:

      .. code-block:: bash

         psql -U kingfisher_collect -h localhost -f kingfisher_collect.sql kingfisher_collect

   #. Copy the ``data`` directory from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:/home/incremental/data/ /home/incremental/data/

   #. Copy the ``logs`` directory from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:/home/incremental/logs/ /home/incremental/logs/

#. Remove the public SSH key from the ``ssh.incremental`` list in the ``pillar/kingfisher_main.sls`` file.
#. Change ``cron.absent`` to ``cron.present`` in the ``salt/kingfisher/collect/incremental.sls`` file.
#. :doc:`Deploy the new server<../deploy>`.

.. _pelican-backend-database-migration:

Pelican backend
~~~~~~~~~~~~~~~

The initial migrations for Pelican backend, which create the ``exchange_rates`` table, are run by Salt.

#. Connect to the old server, and dump the ``exchange_rates`` table:

   .. code-block:: bash

      sudo -i -u postgres psql -c '\copy exchange_rates (valid_on, rates, created, modified) to stdout' pelican_backend > exchange_rates.csv

#. Copy the database dump to your local machine. For example:

   .. code-block:: bash

      rsync -avz root@ocp13.open-contracting.org:~/exchange_rates.csv .

#. Copy the database dump to the new server. For example:

   .. code-block:: bash

      rsync -avz exchange_rates.sql root@ocp23.open-contracting.org:~/

#. Populate the ``exchange_rates`` table:

   .. code-block:: bash

      psql -U pelican_backend -h localhost -c "\copy exchange_rates (valid_on, rates, created, modified) from 'exchange_rates.csv';" pelican_backend

Restore Salt and start jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Change ``cron.absent`` to ``cron.present`` in the ``salt/pelican/backend/init.sls`` file.
#. Uncomment the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the new server<../deploy>`.

Create a data support replica server
------------------------------------

#. Update ``postgres.replica_ipv4`` (and ``postgres.replica_ipv6``, if applicable) in the ``pillar/kingfisher_main.sls`` file.
