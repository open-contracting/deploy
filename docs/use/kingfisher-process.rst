Kingfisher Process
==================

Read the `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

.. note::

   Is the service unresponsive or erroring? :doc:`Follow these instructions<index>`.

.. _kingfisher-process-review-log-files:

Review log files
----------------

Kingfisher Process writes log messages to the ``/var/log/kingfisher.log`` file. The log file is rotated weekly; last week's log file is at ``/var/log/kingfisher.log.1``, and earlier log files are compressed at ``/var/log/kingfisher.log.2.gz``, etc.

The log files can be read by the ``ocdskfp`` user, after :ref:`connecting to the server<connect-kingfisher-server>`.

Log messages are formatted as:

.. code-block:: none

    [date] [hostname] %(asctime)s - %(process)d - %(name)s - %(levelname)s - %(message)s

You can filter messages by topic. For example:

.. code-block:: bash

    grep NAME /var/log/kingfisher.log | less

For more information, read Kingfisher Process' `logging documentation <https://kingfisher-process.readthedocs.io/en/latest/logging.html>`__.

Load local data
---------------

#. :ref:`Connect to the main server as the ocdskfp user<connect-kingfisher-server>`

#. Change into the ``local-load`` directory:

   .. code-block:: bash

      cd ~/local-load

#. Create a data directory following the pattern ``source-YYYY-MM-DD-analyst``. For example: ``moldova-2020-04-07-romina``

   -  If the data source is the same as for an `existing spider <https://github.com/open-contracting/kingfisher-collect/tree/main/kingfisher_scrapy/spiders#files>`__, use the same source ID, for example: ``moldova``. Otherwise, use a different source ID that follows our regular pattern ``country[_region][_label]``, for example: ``moldova_covid19``.

#. If you need to download an archive file (e.g. ZIP) from a remote URL, prefer ``curl`` to ``wget``, because ``wget`` sometimes writes unwanted files like ``wget-log``.

#. If you need to copy a file from your local machine, you can use ``scp``. For example, on your local machine:

.. code-block:: bash

   curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
   scp file.json ocdskfp@process.kingfisher.open-contracting.org:~/local-load/moldova-2020-04-07-romina

#. Load the data, using the `local-load <https://kingfisher-process.readthedocs.io/en/latest/cli/local-load.html>`__ command.

#. Delete the data directory once you're satisfied that it loaded correctly.

Data retention policy
---------------------

On the first day of each month, the following are deleted:

-  Collections that ended over a year ago
-  Collections that never ended and started over 2 months ago
-  Collections that ended over 2 months ago and have no data
