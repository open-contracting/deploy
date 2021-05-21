Kingfisher Summarize
====================

Read the `Kingfisher Summarize <https://kingfisher-summarize.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

.. note::

   Is the service unresponsive or erroring? :doc:`Follow these instructions<index>`.

.. _kingfisher-summarize-review-log-files:

Review log files
----------------

See the :doc:`kingfisher-process` page to :ref:`review log files<kingfisher-process-review-log-files>`. The only differences are that log messages are written to ``/var/log/kingfisher-summarize.log`` and that the topics of log messages are different.

For more information on the topics of log messages, read Kingfisher Summarize's `logging documentation <https://kingfisher-summarize.readthedocs.io/en/latest/logging.html>`__.

Data retention policy
---------------------

On the first day of each month, the following are deleted:

-  Schema whose selected collections no longer exist

To protect a schema from deletion, edit the ``KINGFISHER_SUMMARIZE_PROTECT_SCHEMA`` environment variable in the ``salt/kingfisher/summarize/files/.env`` file.
