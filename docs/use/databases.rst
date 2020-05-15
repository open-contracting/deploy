SQL Databases
=============

Connect to a database
---------------------

.. _psql:

psql
~~~~

If PostgreSQL is installed, you can use `psql <https://www.postgresql.org/docs/current/app-psql.html>`__, PostgreSQL's interactive terminal, from the command-line.

For security, remember to set ``sslmode`` to ``require``.

.. code-block:: bash

   psql "dbname=DBNAME user=USERNAME host=HOST sslmode=require"

For example:

.. code-block:: bash

   psql "dbname=ocdskingfisherprocess user=ocdskfpreadonly host=process.kingfisher.open-contracting.org sslmode=require"

Instead of entering your password each time, you can add your credentials to the `PostgreSQL Password File <https://www.postgresql.org/docs/11/libpq-pgpass.html>`__:

.. code-block:: bash

   echo 'process.kingfisher.open-contracting.org:5432:ocdskingfisherprocess:USER:PASS' >> ~/.pgpass

Then, set the permissions of the ``~/.pgpass`` file:

.. code-block:: bash

   chmod 600 ~/.pgpass

.. _pgadmin:

pgAdmin
~~~~~~~

`pgAdmin <https://www.pgadmin.org>`__ is a locally hosted web interface for querying databases. (You might prefer `Redash <https://redash.open-contracting.org>`__, which is remotely hosted.)

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

Google Colaboratory
~~~~~~~~~~~~~~~~~~~

`Google Colaboratory <https://colab.research.google.com/notebooks/welcome.ipynb>`__ is an executable document to write, run and share code in Google Drive, similar to `Jupyter Notebook <https://jupyter.org>`__.

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

Python
~~~~~~

`Python <https://www.python.org>`__ is the programming language in which many OCDS tools are written.

Install the `psycopg2 <https://pypi.org/project/psycopg2/>`__ Python package.

For security, remember to set ``sslmode`` to ``'require'``.

.. code-block:: python

   import psycopg2

   conn = psycopg2.connect(
       dbname='ocdskingfisherprocess',
       user='ocdskfpreadonly',
       password='PASSWORD',
       host='process.kingfisher.open-contracting.org',
       sslmode='require')
