Kingfisher Process
==================

Read the `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

Review log files
----------------

**Access:**

The logs from Process are available for the ``ocdskfs`` and ``ocdskfp`` users to read.

**Location:**

The newest logs are at ``/var/log/kingfisher.log``. Log rotation is used, and older logs can be found at ``/var/log/kingfisher.log.1`` and other compressed files like ``/var/log/kingfisher.log.2.gz``.

**Understanding:**

Log messages are formatted::

    [date] [hostname] "%(asctime)s - %(process)d - %(name)s - %(levelname)s - %(message)s"

You can look up the meaning of each section `in the Python documentation <https://docs.python.org/3/library/logging.html#logrecord-attributes>`__.

In particular, you can use the name to filter for events you want to see.

.. code-block:: bash

    grep  NAME  /var/log/kingfisher.log  | less

Where ``NAME`` is one of:

ocdskingfisher.checks
  An informative message for each collection, file item, release and record that is checked for structural errors.
ocdskingfisher.cli
  When any CLI command is run, by hand or automatically by a timer.
ocdskingfisher.cli.transform-collections
  When the transform-collections command runs individual collections. Use this to see if a collection is being processed.
ocdskingfisher.database.delete-collection
  To do with deleting collections.
ocdskingfisher.redis-queue
  To do with the processing of the Redis queue.
odskingfisher.web
  An informative message for each web API call.

