Maintain RabbitMQ
=================

.. _rabbitmq-ssh-tunnel:

Access the management interface
-------------------------------

If the management interface is not :ref:`publicly available<rabbitmq-proxy>`:

#. Open an SSH tunnel, replacing ``HOST``:

   .. code-block:: bash

      ssh -N root@HOST -L 15673:localhost:15672

#. Open http://localhost:15673

The Queues tab is the most relevant, to monitor the progress of work. On each queue's page, you can:

-  See the queue’s message rate to estimate when work will complete
-  Purge a queue (that is, remove all messages)
-  Add a message to the queue for debugging

Reference:

-  `Production Checklist <https://www.rabbitmq.com/production-checklist.html>`__
-  `Currently Supported Release Series <https://www.rabbitmq.com/versions.html>`__

Review log files
----------------

RabbitMQ log files are at ``/var/log/rabbitmq/``. ``rabbit@<hostname>.log`` is the main file. ``erl_crash.dump`` describes the latest crash.

Check memory use
----------------

If ``erl_crash.dump`` contains "Slogan: eheap_alloc: Cannot allocate 123456789 bytes of memory (of type "heap").", you can `monitor its memory usage <https://www.rabbitmq.com/memory-use.html#breakdown-cli>`__ and `change its memory thresholds <https://www.rabbitmq.com/memory.html>`__ as needed.

.. seealso::

   `Persistence Configuration <https://www.rabbitmq.com/persistence-conf.html>`__

Troubleshoot
------------

-  Purging a queue does not purge unacked messages. Before purging, stop all consumers to close their channels, which will return the unacked messages to the queue.
-  If you created a binding in error, you must delete the binding, because bindings are persistent. Deleting the queue also deletes the binding.
-  If RabbitMQ restarts, you must restart all consumers, as most consumers do not re-establish connections (same as with PostgreSQL).
