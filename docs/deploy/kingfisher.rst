Kingfisher tasks
================

.. _add-postgresql-user:

Add a PostgreSQL user
---------------------

#. Create the user, as the ``postgres`` user from the ``postgres`` database.

   As root, replace ``password`` with a `strong password <https://www.lastpass.com/password-generator>`__ and ``username`` with a recognizable username (for example, the lowercase first initial and family name of the person, like ``jdoe``), and run:

   .. code-block:: sql

      su - postgres -c "psql postgres -c \"CREATE USER username WITH PASSWORD 'password';\""

#. Add the user to `this spreadsheet <https://docs.google.com/spreadsheets/d/1k5UvY-pMWxDb5-krRny_J3HjN1Y6cpA9sMVAFK7tqsc/edit#gid=0>`__.

Grant read-only access
~~~~~~~~~~~~~~~~~~~~~~

Access is controlled by group membership. The available groups are:

read_kingfisher_process
  ``SELECT`` on all tables in schema ``public``
read_kingfisher_summarize
  ``SELECT`` on all tables in schema created by Kingfisher Summarize

#. Add the user to the group, as the ``postgres`` user from the ``postgres`` database. As root, replace ``group`` and ``user``, and run:

   .. code-block:: bash

      su - postgres -c "psql postgres -c \"GRANT group TO user;\""

#. Update the user's group(s) in `this spreadsheet <https://docs.google.com/spreadsheets/d/1k5UvY-pMWxDb5-krRny_J3HjN1Y6cpA9sMVAFK7tqsc/edit#gid=0>`__.

.. _delete-postgresql-user:

Delete a PostgreSQL user
------------------------

#. Add a temporary state, for example:

   .. code-block:: yaml

      ocdskfpguest:
        postgres_user.absent

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'kingfisher-process' state.sls_id ocdskfpguest kingfisher-process

#. Remove the temporary state

#. Remove the user from `this spreadsheet <https://docs.google.com/spreadsheets/d/1k5UvY-pMWxDb5-krRny_J3HjN1Y6cpA9sMVAFK7tqsc/edit#gid=0>`__.

If the state fails with "User ocdskfpguest failed to be removed":

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
      ssh root@process.kingfisher.open-contracting.org

#. Attempt to drop the given user as the ``postgres`` user, for example:

   .. code-block:: bash

      su - postgres -c 'psql ocdskingfisherprocess -c "DROP ROLE ocdskfpguest;"'

#. You should see a message like:

   .. code-block:: none

      ERROR:  role "ocdskfpguest" cannot be dropped because some objects depend on it
      DETAIL:  privileges for table …
      …
      and 1234 other objects (see server log for list)

#. Open the server log, and search for the relevant ``DROP ROLE`` statement (after running the command below, press ``/``, type ``DROP ROLE``, press Enter, and press ``n`` until you match the relevant statement):

   .. code-block:: bash

      less /var/log/postgresql/postgresql-11-main.log

#. If all the objects listed after ``DETAIL:`` in the server log can be dropped (press Space to scroll forward), then press ``q`` to quit ``less`` and open a SQL terminal as the ``postgres`` user:

   .. code-block:: bash

      su - postgres -c 'psql ocdskingfisherprocess'

#. Finally, delete the given user:

   .. code-block:: sql

      REASSIGN OWNED BY ocdskfpguest TO anotheruser;
      DROP OWNED BY ocdskfpguest;
      DROP ROLE ocdskfpguest;

.. _deploy-kingfisher-process:

Deploy Kingfisher Process without losing Scrapy requests
--------------------------------------------------------

.. note::

   If :ref:`spiders are running<check-if-kingfisher-is-busy>`, use this process. Otherwise, :doc:`deploy as usual<deploy>`.

This should match ``salt/kingfisher/process/init.sls`` (up-to-date as of 2019-12-19). You can ``git log salt/kingfisher/process/init.sls`` to see if there have been any relevant changes, and update this page accordingly.

This assumes that there have been no changes to ``requirements.txt``. If you are adding an index, altering a column, updating many rows, or performing another operation that locks tables or rows for longer than uWSGI's ``harakiri`` setting, this might interfere with an ongoing collection (until queues are fully implemented).

Below, the two key operations are reloading uWSGI with the new application code, and migrating the database.

It's possible for requests to arrive after uWSGI reloads and before the database migrates. If the new application code is not backwards-compatible with the old database schema, the requests might error. If, on the other hand, your old application code is forwards-compatible with the new database schema, then reload uWSGI after migrating the database, instead of before.

``service uwsgi reload`` runs ``/etc/init.d/uwsgi reload``, which sends the SIGHUP signal to the master uWSGI process, which causes it to `gracefully reload <https://uwsgi-docs.readthedocs.io/en/latest/Management.html#reloading-the-server>`__ and not lose any requests from Scrapy.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

#. Connect to the server as the ``ocdskfp`` user and change to the working directory:

   .. code-block:: bash

      curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
      ssh ocdskfp@process.kingfisher.open-contracting.org
      cd ocdskingfisherprocess

#. Check that you won't deploy more commits than you intend, for example:

   .. code-block:: bash

      git fetch
      # From https://github.com/open-contracting/kingfisher-process
      #    d8736f4..173dcf2  master                                  -> origin/master
      git log d8736f4..173dcf2

#. Update the code:

   .. code-block:: bash

      git pull --rebase

#. In a new terminal, connect to the server as the ``root`` user, reload uWSGI, then close your connection to the server:

   .. code-block:: bash

      curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
      ssh root@process.kingfisher.open-contracting.org
      service uwsgi reload

#. In the original terminal, open a terminal multiplexer, in case you lose your connection while migrating the database. You can re-attach to the session with ``tmux attach-session -t deploy``:

   .. code-block:: bash

      tmux new -s deploy

#. If workers are likely to interfere with a migration (e.g. inserting new rows that meet the criteria for an update), comment out the lines that start them in the cron table and kill them:

   .. code-block:: bash

      crontab -e
      pkill -f ocdskingfisher-process-cli

#. Migrate the database (log the time, in case you need to retry):

   .. code-block:: bash

      . .ve/bin/activate
      date
      python ocdskingfisher-process-cli upgrade-database
      date

   Alembic has no verbose mode for upgrades. To see the current queries, open another terminal, open a PostgreSQL shell, and run ``SELECT pid, state, wait_event_type, query FROM pg_stat_activity;``. If a migration query has a ``wait_event_type`` of ``Lock``, look for queries that block it (for example, long-running DELETE queries). To stop a query, run ``SELECT pg_cancel_backend(PID)``, where ``PID`` is the ``pid`` of the query.

#. Uncomment the lines that start the workers in the cron table:

   .. code-block:: bash

      crontab -e

#. Close the session with ``Ctrl-D`` and close your connection to the server.
