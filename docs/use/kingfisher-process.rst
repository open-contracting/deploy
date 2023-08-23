Kingfisher Process
==================

.. warning::

   The documentation for version 2 of Kingfisher Process is not yet ready. In the meantime, the `database structure <https://kingfisher-process.readthedocs.io/en/latest/database-structure.html>`__ remains the same.

.. note::

   Is the service unresponsive or erroring? :doc:`Follow these instructions<index>`.

Load local data
---------------

#. Determine the source ID to use.

   If the data source is the same as for an `existing spider <https://github.com/open-contracting/kingfisher-collect/tree/main/kingfisher_scrapy/spiders#files>`__, use the same source ID, like ``moldova``.

   Otherwise, if the data source has been loaded before, or if you don't know, use a consistent source ID. From a SQL interface, you can list all source IDs with:

   .. code-block:: sql

      SELECT source_id FROM collection GROUP BY source_id ORDER BY source_id;

   If you know the data source had been loaded with a source ID containing "local", get a shorter list of source IDs with:

   .. code-block:: sql

      SELECT source_id FROM collection WHERE source_id LIKE '%local%' GROUP BY source_id ORDER BY source_id;

   If this is the first time loading the data source, use a distinct source ID that follows the pattern ``country[_region][_label]``, like ``moldova_covid19``.

#. :ref:`Connect to the data support server<connect-kingfisher-server>`.
#. Create a data directory in your ``local-load`` directory, following the pattern ``source-YYYY-MM-DD``:

   .. code-block:: bash

      mkdir ~/local-load/moldova-2020-04-07

#. Copy the files to load into the data directory.

   If you need to download an archive file (e.g. ZIP) from a remote URL, prefer ``curl`` to ``wget``, because ``wget`` sometimes writes unwanted files like ``wget-log``.

   If you need to copy files from your local machine, you can use ``rsync`` (fast) or ``scp`` (slow). For example, on your local machine:

   .. code-block:: bash

      rsynz -avz file.json USER@collect.kingfisher.open-contracting.org:~/local-load/moldova-2020-04-07

#. Load the data. For example:

   .. code-block:: bash

      sudo -u deployer /opt/kingfisher-process/load.sh --source moldova_covid19 --note "Added by NAME" --compile --check /home/USER/local-load/moldova-2020-04-07

   If you don't need to check for structural errors, omit the ``--check`` flag. For a description of all options, run:

   .. code-block:: bash

      sudo -u deployer /opt/kingfisher-process/load.sh --help

   .. note::

      Kingfisher Process can keep the collection open for more files to be added later, by using the ``--keep-open`` flag with the ``load`` command. To learn how to use the additional commands, run:

      .. code-block:: bash

         sudo -u deployer /opt/kingfisher-process/addfiles.sh --help
         sudo -u deployer /opt/kingfisher-process/closecollection.sh --help

#. Delete the data directory once you're satisfied that it loaded correctly.

Remove a collection
-------------------

#. :ref:`Connect to the data support server<connect-kingfisher-server>`.
#. Remove the collection:

   .. code-block:: bash

      sudo -u deployer /opt/kingfisher-process/deletecollection.sh 123

Check on progress
-----------------

Using the command-line interface
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. :ref:`Connect to the data support server<connect-kingfisher-server>`.
#. Check the collection status, replacing the collection ID (``123``).

   .. code-block:: shell-session

      $ sudo -u deployer /opt/kingfisher-process/collectionstatus.sh 123
      steps: check, compile
      data_type: release package
      store_end_at: 2023-06-28 22:13:00.067783
      completed_at: 2023-06-28 23:29:37.825645
      expected_files_count: 1
      collection_files: 1
      processing_steps: 0

      Compiled collection
      compilation_started: True
      store_end_at: 2023-06-28 22:13:04.060873
      completed_at: 2023-06-28 22:13:04.060873
      collection_files: 277
      processing_steps: 0

   This output means processing is complete. To learn how to interpret the output, run:

   .. code-block:: bash

      sudo -u deployer /opt/kingfisher-process/collectionstatus.sh --help

.. _kingfisher-process-rabbitmq:

Using RabbitMQ
~~~~~~~~~~~~~~

Kingfisher Process uses a message broker, `RabbitMQ <https://www.rabbitmq.com>`__, to organize its tasks into queues. You can login to the `RabbitMQ management interface <https://rabbitmq.kingfisher.open-contracting.org>`__ to see the status of the queues and check that it's not stuck.

#. Open https://rabbitmq.kingfisher.open-contracting.org. Your username and password are the same as for :ref:`Kingfisher Collect<access-scrapyd-web-service>`.
#. Click on the `Queues <https://rabbitmq.kingfisher.open-contracting.org/#/queues>`__ tab.
#. Read the rows in which the *Name* starts with ``kingfisher_process_``.

   -  If the *Messages* are non-zero, then there is work to do. If zero, then work is done! (Everything except the checker is fast – don't be surprised if it's zero.)
   -  If the *Message rates* are non-zero, then work is progressing. If zero, and if there is work to do, then it is stuck!

   If you think work is stuck, notify James or Yohanna.

Export compiled releases from the database as record packages
-------------------------------------------------------------

Check the number of compiled releases to be exported. For example:

.. code:: sql

   SELECT cached_compiled_releases_count FROM collection WHERE id = 123;

.. attention::

   The ``cached_compiled_releases_count`` column is not yet populated in version 2 of Kingfisher Process (`#370 <https://github.com/open-contracting/kingfisher-process/issues/370>`__). In the meantime, you can run:

   .. code:: sql

      SELECT COUNT(*) FROM compiled_release WHERE collection_id = 123;

Change to the directory in which you want to write the files.

.. tip::

   Large collections will take time to export, so run the commands below in a ``tmux`` session.

To export the compiled releases to a single JSONL file, run, for example:

.. code:: bash

   psql "connection string" -c '\t' \
   -c 'SELECT data FROM data INNER JOIN compiled_release r ON r.data_id = data.id WHERE collection_id = 123' \
   -o myfilename.jsonl

To export the compiled releases to individual files, run, for example:

.. code:: bash

   psql "connection string" -c '\t' \
   -c 'SELECT data FROM data INNER JOIN compiled_release r ON r.data_id = data.id WHERE collection_id = 123' \
   | split -l 1 -a 5 --additional-suffix=.json

The files will be named ``xaaaaa.json``, ``xaaaab.json``, etc. ``-a 5`` is sufficient for 11M files (26⁵).

If you need to wrap each compiled release in a record package, modify the files in-place. For example:

.. code:: bash

   echo *.json | xargs sed -i '1i {"records":[{"compiledRelease":'
   for filename in *.json; do echo "}]}" >> "$filename"; done

Data retention policy
---------------------

On the first day of each month, the following are deleted:

-  Collections that ended over a year ago, while retaining one set of collections per source from over a year ago
-  Collections that never ended and started over 2 months ago
-  Collections that ended over 2 months ago and have no data
