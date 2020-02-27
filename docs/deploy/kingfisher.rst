Kingfisher tasks
================

.. _access-scrapyd-web-service:

Access Scrapyd's web interface
------------------------------

Open http://scrape.kingfisher.open-contracting.org

.. _connect-collect-server:

Connect to the Kingfisher Scrape server
---------------------------------------

Connect to the server as the ``ocdskfs`` user:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org

Collect data with Kingfisher Scrape
-----------------------------------

`Read its documentation <https://kingfisher-scrape.readthedocs.io/en/latest/>`__, which covers general usage.

#. :ref:`Connect to the server<connect-collect-server>`

#. Schedule a crawl and set its note and any other `spider arguments <https://kingfisher-scrape.readthedocs.io/en/latest/use-cases/local.html#collect-data>`__. For example, replace ``spider_name`` with a spider's name and ``NAME`` with your name:

   .. code-block:: bash

      curl http://localhost:6800/schedule.json -d project=kingfisher -d spider=spider_name -d note="Started by NAME."

Access Scrapyd's crawl logs
---------------------------

From a browser, click on a "Log" link from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__, or open Scrapyd's `logs page for the kingfisher project <http://scrape.kingfisher.open-contracting.org/logs/kingfisher/>`__.

From the command-line, connect to the server as the ``ocdskfs`` user, and change to the logs directory for the ``kingfisher`` project:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org
   cd scrapyd/logs/kingfisher

Scrapy statistics are extracted from the end of each log file every hour on the hour, into a new file ending in ``_report.log`` in the same directory as the log file. Access as above, or, from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__:

-  Right-click on a "Log" link.
-  Select "Copy Link" or similar.
-  Paste the URL into the address bar.
-  Change ``.log`` at the end of the URL to ``_report.log`` and press Enter.

Update spiders in Kingfisher Scrape
-----------------------------------

#. Merge your changes to the master branch of the `kingfisher-scrape repository <https://github.com/open-contracting/kingfisher-scrape>`__.

#. Connect to the server as the ``ocdskfs`` user and change to the working directory:

   .. code-block:: bash

      ssh ocdskfs@scrape.kingfisher.open-contracting.org
      cd ocdskingfisherscrape

#. Pull your changes into the local repository:

   .. code-block:: bash

      git pull --rebase

#. Activate the virtual environment and Update the project's requirements:

   .. code-block:: bash

      source .ve/bin/activate
      pip install -r requirements.txt

#. Deploy the spiders:

   .. code-block:: bash

         scrapyd-deploy

Deploy Kingfisher Process without losing Scrapy requests
--------------------------------------------------------

This should match ``salt/ocdskingfisherprocess.sls`` (up-to-date as of 2019-12-19). You can ``git log salt/ocdskingfisherprocess.sls`` to see if there have been any relevant changes, and update this page accordingly.

This assumes that there have been no changes to ``requirements.txt``. If you are adding an index, altering a column, updating many rows, or performing another operation that locks tables or rows for longer than uWSGI's ``harakiri`` setting, this might interfere with an ongoing collection (until queues are fully implemented).

Below, the two key operations are reloading uWSGI with the new application code, and migrating the database.

It's possible for requests to arrive after uWSGI reloads and before the database migrates. If the new application code is not backwards-compatible with the old database schema, the requests might error. If, on the other hand, your old application code is forwards-compatible with the new database schema, then reload uWSGI after migrating the database, instead of before.

``service uwsgi reload`` runs ``/etc/init.d/uwsgi reload``, which sends the SIGHUP signal to the master uWSGI process, which causes it to `gracefully reload <https://uwsgi-docs.readthedocs.io/en/latest/Management.html#reloading-the-server>`__ and not lose any requests from Scrapy.

As with other deployment tasks, do the :doc:`setup tasks<setup>` before (and the cleanup tasks after) the steps below.

#. Connect to the server as the ``ocdskfp`` user and change to the working directory:

   .. code-block:: bash

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

      ssh root@process.kingfisher.open-contracting.org
      service uwsgi reload

#. In the original terminal, open a terminal multiplexer, in case you lose your connection while migrating the database. You can re-attach to the session with ``tmux attach-session -t deploy``:

   .. code-block:: bash

      tmux new -s deploy

#. If workers are likely to interfere with a migration (e.g. inserting new rows that meet the criteria for an update), comment out the lines that start them in the cron table and kill them:

   .. code-block:: bash

      crontab -e
      pkill -f ocdskingfisher-process-cli

#. Migrate the database (log the time, in case you need to retry). Alembic has no verbose mode for upgrades. To see the current queries, open another terminal, open a PostgreSQL shell, and run ``SELECT pid, state, wait_event_type, query FROM pg_stat_activity;``. If a migration query has a ``wait_event_type`` of ``Lock``, look for queries that block it (for example, long-running DELETE queries). To stop a query, run ``SELECT pg_cancel_backend(PID)``, where ``PID`` is the ``pid`` of the query.

   .. code-block:: bash

      . .ve/bin/activate
      date
      python ocdskingfisher-process-cli upgrade-database
      date

#. Uncomment the lines that start the workers in the cron table:

   .. code-block:: bash

      crontab -e

#. Close the session with ``Ctrl-D`` and close your connection to the server.
