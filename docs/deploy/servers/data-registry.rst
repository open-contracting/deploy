Data registry
=============

.. _data-registry-migrate:

Migrate from an old server
--------------------------

Dependencies
~~~~~~~~~~~~

Tinyproxy
  #. Update the allowed IP addresses in the ``pillar/tinyproxy.sls`` file.
  #. Deploy the ``docs`` service, when ready.

Update Salt configuration and halt jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Check that ``docker.uid`` in the server's Pillar file matches the entry in the ``/etc/passwd`` file for the ``docker.user`` (``deployer``).
#. Change ``cron.present`` to ``cron.absent`` in the ``salt/registry/init.sls`` file.
#. Change ``cron.present`` to ``cron.absent`` in the ``salt/pelican/backend/init.sls`` file.
#. Comment out the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the old server and the new server<../deploy>`.
#. On the old server:

   #. Delete the ``/etc/cron.d/postgres_backups`` file.
   #. ``docker compose down`` all containers, except the ``web`` and ``static`` containers of the ``data-registry`` service.

#. Check that no crawls are running at https://collect.data.open-contracting.org/jobs.

   If a crawl is running, Django administrators can `cancel jobs <https://data.open-contracting.org/admin/data_registry/job/?status__exact=RUNNING>`__.

#. Check that no messages are enqueued at https://rabbitmq.data.open-contracting.org.

   If a job is running in Kingfisher Process, job owners can `cancel jobs <https://kingfisher-process.readthedocs.io/en/latest/cli.html#cancelcollection>`__.

Filesystem
~~~~~~~~~~

Copy these directories from the old server to the new server, using ``rsync -avz``:

-  ``/data/storage/exporter``
-  ``/data/storage/spoonbill``
-  ``/home/collect/scrapyd/dbs``
-  ``/home/collect/scrapyd/eggs``
-  ``/home/collect/scrapyd/logs``

Databases
~~~~~~~~~

#. Copy the ``data_registry`` and ``spoonbill`` databases from the old server to the new server, :ref:`using pg_dump<pg-recover-backup-universal>`.
#. Copy the :ref:`exchange_rates rows<pelican-backend-database-migration>` from the old server to the new server.

Docker apps
~~~~~~~~~~~

Perform the same tasks as for :ref:`Data support<kingfisher-pelican-docker-migration>`.

Restore Salt and start jobs
~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Change ``cron.absent`` to ``cron.present`` in the ``salt/registry/init.sls`` file.
#. Change ``cron.absent`` to ``cron.present`` in the ``salt/pelican/backend/init.sls`` file.
#. Uncomment the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the new server<../deploy>`.
