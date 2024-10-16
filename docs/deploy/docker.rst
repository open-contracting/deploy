Docker tasks
============

Update applications
-------------------

Change to the application's directory, replacing ``APP``:

.. code-block:: bash

   cd /data/deploy/APP

`Pull new images <https://docs.docker.com/reference/cli/docker/compose/pull/>`__ and `start new containers <https://docs.docker.com/reference/cli/docker/compose/up/>`__:

.. code-block:: bash

   docker compose pull
   docker compose up -d

Migrate the database, for example:

.. code-block:: bash

   docker compose run --rm --name my-app-migrate cron python manage.py migrate

.. admonition:: One-time setup

   Create a superuser, if applicable:

   .. code-block:: bash

      docker compose run --rm --name my-app-superuser cron python manage.py createsuperuser

Revert images
~~~~~~~~~~~~~

#. Find the SHA of the previous image:

   .. code-block:: bash

      docker image ls --digests

   If the previous image has been pruned, visit the package's page, like `kingfisher-process-django <https://github.com/open-contracting/kingfisher-process/pkgs/container/kingfisher-process-django/versions>`__.

#. Change the image in the Docker Compose file from ``myproject:latest`` to ``myproject@sha256:0ed5d59...``.

#. Start new containers:

   .. code-block:: bash

      docker compose pull
      docker compose up -d

Load data
---------

For example:

.. code-block:: bash

   psql -U pelican_backend -h localhost -c "\copy exchange_rates (valid_on, rates, created, modified) from 'exchange_rates.csv';" pelican_backend

Check that the ID sequence is correct:

.. code-block:: sql

   SELECT MAX(id) FROM exchange_rates;
   SELECT nextval('exchange_rates_id_seq');

The second value should be higher than the first. If not:

.. code-block:: sql

   SELECT setval('exchange_rates_id_seq', COALESCE((SELECT MAX(id) + 1 FROM exchange_rates), 1), false);
