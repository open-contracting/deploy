Kingfisher tasks
================

Deploy Kingfisher Process without losing Scrapy requests
--------------------------------------------------------

This should match ``salt/ocdskingfisherprocess.sls`` (up-to-date as of 2019-12-19). You can ``git log salt/ocdskingfisherprocess.sls`` to see if there have been any relevant changes, and update this page accordingly.

This assumes that there have been no changes to ``requirements.txt``. If you are adding an index or performing an operation that locks tables for longer than uWSGI's ``harakiri`` setting, this might interfere with an ongoing collection (until queues are fully implemented).

Below, the two key operations are reloading uWSGI with the new application code, and migrating the database.

It's possible for requests to arrive after uWSGI reloads and before the database migrates. If the new application code is not backwards-compatible with the old database schema, the requests might error. If, on the other hand, your old application code is forwards-compatible with the new database schema, then reload uWSGI after migrating the database, instead of before.

Note: ``service uwsgi reload`` runs ``/etc/init.d/uwsgi reload``, which sends the SIGHUP signal to the master uWSGI process, which causes it to `gracefully reload <https://uwsgi-docs.readthedocs.io/en/latest/Management.html#reloading-the-server>`__ and not lose a single request from Scrapy.

#. `Get the deploy token <https://ocdsdeploy.readthedocs.io/en/latest/how-to/deploy.html#get-deploy-token>`__.

#. Connect to the server as the ``ocdskfp`` user and change into the working directory:

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

      ssh root@process.kingfisher.open-contracting.org
      service uwsgi reload

#. In the original terminal, open a terminal multiplexer, in case you lose your connection to the server while migrating the database. You can re-attach to the session with ``tmux attach-session -t deploy``:

   .. code-block:: bash

      tmux new -s deploy

#. If workers are likely to interfere with a migration (e.g. inserting new rows that need to be migrated), comment out the lines that start the workers in the cron table and kill the workers, for example:

   .. code-block:: bash

      crontab -e
      pkill -f " process-redis-queue "

#. Migrate the database:

   .. code-block:: bash

      . .ve/bin/activate
      python ocdskingfisher-process-cli upgrade-database

#. Uncomment the lines that start the workers in the cron table:

   .. code-block:: bash

      crontab -e

#. Close the session with ``Ctrl-D`` and close your connection to the server.
