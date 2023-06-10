Docker tasks
============

.. note::

   The commands assume Compose V2, which uses ``docker compose``. For Compose V1, use ``docker-compose`` (with hyphen).

Change to the application's directory, replacing ``APP``:

.. code-block:: bash

   cd /data/deploy/APP

`Pull new images <https://docs.docker.com/engine/reference/commandline/compose_pull/>`__ and `start new containers <https://docs.docker.com/engine/reference/commandline/compose_up/>`__:

.. code-block:: bash

   docker compose pull
   docker compose up -d

Create a superuser:

.. code-block:: bash

   docker compose run --rm web python manage.py createsuperuser

Migrate the database:

.. code-block:: bash

   docker compose run --rm web python manage.py migrate

.. note::

   If you are using a `postgres <https://hub.docker.com/_/postgres/>`__ image, see its "Arbitrary ``--user`` Notes" section.

   Remember that volume names are, by default, prefixed by the directory name: for example, ``spoonbill_postgresql-data``.

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
