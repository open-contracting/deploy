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
