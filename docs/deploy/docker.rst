Docker tasks
============

Change to the application's directory, replacing ``APP``:

.. code-block:: bash

   cd /data/deploy/APP

Create a superuser:

.. code-block:: bash

   docker-compose run $(cat .env | xargs printf -- ' -e %s') --rm web python manage.py createsuperuser

Migrate the database:

.. code-block:: bash

   docker-compose run $(cat .env | xargs printf -- ' -e %s') --rm web python manage.py migrate

Load data into the database. For example:

.. code-block:: bash

   psql -c 'SET ROLE pelican_backend' -c "\copy exchange_rates (id, valid_on, rates, created, modified) from '/opt/pelican-backend/exchange_rates.csv' delimiter ',' csv header;" pelican_backend
