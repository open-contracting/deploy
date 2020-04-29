Kingfisher Process
==================

Read the `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

.. _connect-process-server:

Connect to the Kingfisher Process server
----------------------------------------

.. admonition:: One-time setup

   Ask a colleague to add your SSH key to ``salt/private/authorized_keys/kingfisher_to_add``

Connect to the server as the ``ocdskfp`` user:

.. code-block:: bash

   ssh ocdskfp@process.kingfisher.open-contracting.org

Review log files
----------------

Kingfisher Process writes log messages to the ``/var/log/kingfisher.log`` file. The log file is rotated weekly; last week's log file is at ``/var/log/kingfisher.log.1``, and earlier log files are compressed at ``/var/log/kingfisher.log.2.gz``, etc.

The log files can be read by the ``ocdskfs`` and ``ocdskfp`` users, after :ref:`connecting to the server<connect-process-server>`.

Log messages are formatted as::

    [date] [hostname] %(asctime)s - %(process)d - %(name)s - %(levelname)s - %(message)s

You can filter messages by topic. For example:

.. code-block:: bash

    grep NAME /var/log/kingfisher.log | less

For more information, read Kingfisher Process' `logging documentation <https://kingfisher-process.readthedocs.io/en/latest/logging.html>`__.
