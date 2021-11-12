RabbitMQ
========

Access the management interface
-------------------------------

#. Open an SSH tunnel, replacing ``HOST``:

   .. code-block:: bash

      curl --silent --connect-timeout 1 HOST:8255 || true
      ssh -N root@HOST -L 15673:localhost:15672

#. Open http://localhost:15673

The Queues tab is the most relevant, to monitor the progress of work. On each queue's page, you can:

-  See the queue’s message rate to estimate when work will complete
-  Purge a queue (that is, remove all messages)
-  Add a message to the queue for debugging

Reference:

-  `Production Checklist <https://www.rabbitmq.com/production-checklist.html>`__
-  `Currently Supported Release Series <https://www.rabbitmq.com/versions.html>`__

Troubleshoot
------------

-  Purging a queue does not purge unacked messages. Before purging, stop all consumers to close their channels, which will return the unacked messages to the queue.
-  If you created a binding in error, you must delete the binding, because bindings are persistent. Deleting the queue also deletes the binding.
-  If RabbitMQ restarts, you must restart all consumers, as most consumers do not re-establish connections (same as with PostgreSQL).
