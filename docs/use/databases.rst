SQL databases
=============

.. note::

   If you need to create temporary tables, use ``CREATE TEMPORARY TABLE``. If you need to create persistent tables, create a new schema first; do not create tables in the ``public`` schema.

Connect to a database
---------------------

.. note::

   To query the database directly from your personal computer, request a personal SQL user account from James or Yohanna, and configure :ref:`psql`, :ref:`beekeeper` and/or :ref:`pgadmin` to use it.

OCP has a main database on the ``postgres.kingfisher.open-contracting.org`` server.

.. _psql:

psql
~~~~

If PostgreSQL is installed, you can use `psql <https://www.postgresql.org/docs/current/app-psql.html>`__, PostgreSQL's interactive terminal, from the command-line.

For security, remember to set ``sslmode`` to ``require``.

.. code-block:: bash

   psql "dbname=DBNAME user=USERNAME host=HOST sslmode=require"

For example:

.. code-block:: bash

   psql "dbname=kingfisher_process user=jmckinney host=postgres.kingfisher.open-contracting.org sslmode=require"

Instead of entering your password each time, you can add your credentials to the `PostgreSQL Password File <https://www.postgresql.org/docs/current/libpq-pgpass.html>`__, replacing ``USER`` and ``PASS``:

.. code-block:: bash

   echo 'postgres.kingfisher.open-contracting.org:5432:kingfisher_process:USERNAME:PASSWORD' >> ~/.pgpass

Then, set the permissions of the ``~/.pgpass`` file:

.. code-block:: bash

   chmod 600 ~/.pgpass

.. tip::

   If you are logged into the ``postgres.kingfisher.open-contracting.org`` server, you can also run:

   .. code-block:: bash

      psql kingfisher_process

.. _beekeeper:

Beekeeper Studio
~~~~~~~~~~~~~~~~

`Beekeeper Studio <https://www.beekeeperstudio.io>`__ is a cross-platform app for querying databases. Use the open-source `Community Edition <https://www.beekeeperstudio.io/get-community>`__.

For security, remember to check *Enable SSL*.

#. Select "Postgres" from *Connection Type*
#. Set the *Host*, e.g. "postgres.kingfisher.open-contracting.org"
#. Check *Enable SSL*
#. Set the *User*
#. Set the *Password*
#. Set the *Default Database*, e.g. "kingfisher_process"
#. Click the *Test* button

Then, either click the *Connect* button or set the *Connection Name* and click *Save*.

.. _pgadmin:

pgAdmin
~~~~~~~

`pgAdmin <https://www.pgadmin.org>`__ is a locally hosted web interface for querying databases.

For security, remember to set *SSL mode* to "Require".

#. Open the *Object > Create > Server...* menu item
#. Set the *Name*, e.g. "Kingfisher"
#. Click the *Connection* tab
#. Set the *Host name/address*, e.g. "postgres.kingfisher.open-contracting.org"
#. Set the *Username*
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

Install the `ocdskingfishercolab <https://pypi.org/project/ocdskingfishercolab/>`__ Python package, which installs the `ipython-sql <https://pypi.org/project/ipython-sql/>`__ Python package.

For security, remember to set ``sslmode`` to ``'require'``.

.. code-block:: none

   %sql postgresql://USERNAME:PASSWORD@postgres.kingfisher.open-contracting.org/kingfisher_process?sslmode=require

.. note::

   There is an open issue to use `Colaboratory Forms <https://colab.research.google.com/notebooks/forms.ipynb>`__ to store credentials.

Python
~~~~~~

`Python <https://www.python.org>`__ is the programming language in which many OCDS tools are written.

Install the `psycopg2 <https://pypi.org/project/psycopg2/>`__ Python package.

For security, remember to set ``sslmode`` to ``'require'``.

.. code-block:: python

   import psycopg2

   conn = psycopg2.connect(
       dbname='kingfisher_process',
       user='USER',
       password='PASSWORD',
       host='postgres.kingfisher.open-contracting.org',
       sslmode='require')

.. _improve-slow-queries:

Improve slow queries
--------------------

.. seealso::

   `PostgreSQL <https://ocp-software-handbook.readthedocs.io/en/latest/services/postgresql.html>`__ in the Software Development Handbook

To see the queries running under your user account, run:

.. code-block:: sql

   SELECT pid, client_addr, usename, state, wait_event_type, NOW() - query_start AS time, query
   FROM pg_stat_activity
   WHERE query <> ''
   ORDER BY time DESC;

Find your username in the ``usename`` column. The ``time`` column indicates how long the query has run for. If it is longer than one minute, it is slow.

In general, a query is slow due to not using indexes for its ``JOIN`` and/or ``WHERE`` clauses. Using indexes can decrease the running time from hours/days to seconds.

.. tip::

   For tables created by `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/database.html#how-tables-are-related>`__, always ``JOIN`` on the ``id`` column, which has an index, and never on the ``ocid`` column, which has *no* index.

To see the indexes on a table, run ``\d TABLE_NAME``. A view cannot have indexes; instead, check the indexes on the tables it queries. To see a view's query, run ``\d+ VIEW_NAME``.

If the columns in the query's ``JOIN`` and/or ``WHERE`` clauses aren't indexed, and you can't change the clauses to use columns that are indexed, open an issue on GitHub about adding an index to the table.

To stop a query, run, replacing ``PID`` with the appropriate value from the ``pid`` column:

.. code-block:: sql

   SELECT pg_cancel_backend(PID)
