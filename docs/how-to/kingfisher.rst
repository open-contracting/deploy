Kingfisher tasks
================

Deploy Kingfisher Process without interrupting a Scrapy crawl
-------------------------------------------------------------

This should match ``salt/ocdskingfisherprocess.sls`` (up-to-date as of 2019-12-19). You can ``git log salt/ocdskingfisherprocess.sls`` to see if there have been any relevant changes, and update this page accordingly.

This assumes that there have been no changes to ``requirements.txt``. If you are adding indexes or performing operations that lock tables, this might interfere with an ongoing collection (until queues are fully implemented).

#. Connect to the server and change into the working directory:

   .. code-block:: bash

      ssh ocdskfp@process.kingfisher.open-contracting.org
      cd ocdskingfisherprocess

#. Check that you won't deploy more commits than you intend, for example:

   .. code-block:: bash

      git fetch
      # From https://github.com/open-contracting/kingfisher-process
      #    d8736f4..173dcf2  master                                  -> origin/master
      git log d8736f4..173dcf2

#. Open a terminal multiplexer, in case you lose your connection to the server. You can re-attach to the session with ``tmux attach-session -t deploy``:

   .. code-block:: bash

      tmux new -s deploy

#. Deploy:

   .. code-block:: bash

      git pull --rebase
      . .ve/bin/activate
      python ocdskingfisher-process-cli upgrade-database
      service uwsgi reload

#. Close the session with ``Ctrl-D`` and close your connection to the server.
