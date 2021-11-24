Docker tasks
============

Change to the application's directory, replacing ``APP``:

.. code-block:: bash

   cd /data/deploy/APP

Create a superuser:

.. code-block:: bash

   docker-compose run --rm web python manage.py createsuperuser

Migrate the database:

.. code-block:: bash

   docker-compose run --rm web python manage.py migrate

Load data into the database. For example:

.. code-block:: bash

   psql -c "\copy exchange_rates (valid_on, rates) from '/opt/pelican-backend/exchange_rates.csv' delimiter ',' csv header;" pelican_backend
