SQL Databases
=============

Connect
-------

Using psql
~~~~~~~~~~

.. code-block:: bash

   psql DBNAME USERNAME -h HOST

For example:

   psql ocdskingfisherprocess ocdskfpreadonly -h process.kingfisher.open-contracting.org

Instead of entering your password each time, you can add your credentials to the `PostgreSQL Password File <https://www.postgresql.org/docs/11/libpq-pgpass.html>`__:

.. code-block:: bash

   echo 'process.kingfisher.open-contracting.org:5432:ocdskingfisherprocess:USER:PASS' >> ~/.pgpass

Then, set the permissions of the ``~/.pgpass`` file:

.. code-block:: bash

   chmod 600 ~/.pgpass

Using pgAdmin
~~~~~~~~~~~~~

For security, remember to set *SSL mode* to "Require".

#. Open the *Object > Create > Server...* menu item
#. Set the *Name*, e.g. "Kingfisher"
#. Click the *Connection* tab
#. Set the *Host name/address*, e.g. "process.kingfisher.open-contracting.org"
#. Set the *Username*, e.g. "ocdskfpreadonly"
#. Set the *Password*
#. Check *Save password?*
#. Click the *SSL* tab
#. Set *SSL mode* to "Require"
#. Click the *Save* button

To avoid unnecessary queries to the database, please make these one-time configuration changes:

#. Open the *File > Preferences* menu item
#. Click *Display* under *Dashboards* in the sidebar
#. Uncheck *Show activity?*
#. Uncheck *Show graphs?*
#. Click the *Save* button

Using Google Colaboratory
~~~~~~~~~~~~~~~~~~~~~~~~~

Install the `ocdskingfishercolab <https://pypi.org/project/ocdskingfishercolab/>`__ Python package.

For security, remember to set ``sslmode`` to ``'require'``.

.. code-block:: python

   from ocdskingfishercolab import create_connection

   conn = create_connection(
       database='ocdskingfisherprocess',
       user='ocdskfpreadonly',
       password='PASSWORD',
       host='process.kingfisher.open-contracting.org',
       sslmode='require')

Using Python
~~~~~~~~~~~~

Install the `psycopg2 <https://pypi.org/project/psycopg2/>`__ Python package.

For security, remember to set ``sslmode`` to ``'require'``.

.. code-block:: python

   import psycopg2

   psycopg2.connect(
       dbname='ocdskingfisherprocess',
       user='ocdskfpreadonly',
       password='PASSWORD',
       host='process.kingfisher.open-contracting.org',
       sslmode='require')

Using Redash
~~~~~~~~~~~~

The connection is configured for all users at https://redash.open-contracting.org/data_sources
