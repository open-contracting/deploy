Data registry
=============

.. _data-registry-migrate:

Migrate from an old server
--------------------------

Update Salt
~~~~~~~~~~~

.. seealso::

   :doc:`../create_server`

#. Check that ``docker.uid`` in the ``pillar/kingfisher_main.sls`` file matches the entry in the ``/etc/passwd`` file for the ``docker.user`` (``deployer``).
#. Change ``cron.present`` to ``cron.absent`` in the ``salt/pelican/backend/init.sls`` file.
#. Change ``cron.present`` to ``cron.absent`` in the ``salt/registry/init.sls`` file.
#. Comment out the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the old server and the new server<../deploy>`.
#. Delete the ``/etc/cron.d/postgres_backups`` file on the old server.

Check that no crawls are running at https://collect.data.open-contracting.org, and no messages are enqueued at https://rabbitmq.data.open-contracting.org.

Filesystem
~~~~~~~~~~

Copy these directories from the old server to the new server:

-  ``/data/storage/exporter``
-  ``/data/storage/spoonbill``
-  ``/home/collect/scrapyd/logs``

Databases
~~~~~~~~~

Docker apps
~~~~~~~~~~~

#. Run migrations for :doc:`Docker apps<../docker>` as the ``deployer`` user:

   .. code-block:: bash

      su - deployer

      cd /data/deploy/kingfisher-process/
      docker compose run --rm --name kingfisher-process-migrate cron python manage.py migrate

      cd /data/deploy/pelican-frontend/
      docker compose run --rm --name pelican-frontend-migrate cron python manage.py migrate

#. :doc:`Pull new images and start new containers for each Docker app<../docker>`.

Kingfisher Collect
~~~~~~~~~~~~~~~~~~

Once DNS has propagated, :ref:`update-spiders`, but with:

.. code-block::

   scrapyd-deploy registry

Pelican backend
~~~~~~~~~~~~~~~

The initial migrations for Pelican backend are run by Salt.

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

Restore Salt
~~~~~~~~~~~~

#. Change ``cron.absent`` to ``cron.present`` in the ``salt/pelican/backend/init.sls`` file.
#. Change ``cron.absent`` to ``cron.present`` in the ``salt/registry/init.sls`` file.
#. Uncomment the ``postgres.backup`` section of the Pillar file.
#. :doc:`Deploy the new server<../deploy>`.
