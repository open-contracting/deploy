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
