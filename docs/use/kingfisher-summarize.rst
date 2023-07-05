Kingfisher Summarize
====================

Read the `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

.. note::

   Is the service unresponsive or erroring? :doc:`Follow these instructions<index>`.

Summarize collections
---------------------

#. :ref:`Connect to the data support server<connect-kingfisher-server>`
#. Open a session in :ref:`tmux<tmux>`:

   .. code-block:: bash

      tmux new -s initials-task-description

#. Run the `command-line tool <https://kingfisher-summarize.readthedocs.io/en/latest/cli.html>`__, using the ``/opt/kingfisher-summarize.sh`` entrypoint. (This runs ``manage.py`` indirectly.) For example:

   .. code-block:: bash

      sudo -u summarize /opt/kingfisher-summarize.sh add --help

   .. code-block:: bash

      sudo -u summarize /opt/kingfisher-summarize.sh add 123 "Added by NAME"

   .. tip::

      Use the ``--field-lists`` option to analyze coverage:

      .. code-block:: bash

         sudo -u summarize /opt/kingfisher-summarize.sh add 123 "added by NAME" --field-lists

#. Close the session by pressing ``Ctrl-d`` or by running:

   .. code-block:: bash

      exit

Review log files
----------------

Kingfisher Summarize writes log messages to the ``/var/log/kingfisher-summarize.log`` file. The log file is rotated weekly; last week's log file is at ``/var/log/kingfisher-summarize.log.1``, and earlier log files are compressed at ``/var/log/kingfisher-summarize.log.2.gz``, etc.

Log messages are formatted as:

.. code-block:: none

   [date] [hostname] %(asctime)s - %(process)d - %(name)s - %(levelname)s - %(message)s

You can filter messages by topic. For example:

.. code-block:: bash

   grep NAME /var/log/kingfisher-summarize.log | less

For more information on the topics of log messages, read Kingfisher Summarize's `logging documentation <https://kingfisher-summarize.readthedocs.io/en/latest/logging.html>`__.

Data retention policy
---------------------

On the first day of each month, the following are deleted:

-  Schema whose selected collections no longer exist

To protect a schema from deletion, edit the ``KINGFISHER_SUMMARIZE_PROTECT_SCHEMA`` environment variable in the ``salt/kingfisher/summarize/files/.env`` file.
