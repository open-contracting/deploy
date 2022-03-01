Configure RabbitMQ
==================

Add service accounts
--------------------

To configure the message broker for an application:

#. Add a user for the application, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/password-generator>`__ (uncheck *Symbols*) and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      rabbitmq:
        users:
          USERNAME:
            password: "PASSWORD"

#. To give the user access to the management interface, add:

   .. code-block:: yaml
      :emphasize-lines: 5-6

      rabbitmq:
        users:
          USERNAME:
            password: "PASSWORD"
            tags:
              - management

#. To give the user access to `memory use <https://www.rabbitmq.com/memory-use.html>`__, add:

   .. code-block:: yaml
      :emphasize-lines: 7

      rabbitmq:
        users:
          USERNAME:
            password: "PASSWORD"
            tags:
              - management
              - monitoring

#. Add the private Pillar file to the top file entry for the application.

.. note::

   The default user named ``guest`` is deleted by default. To retain the user, update the server's Pillar file:

   .. code-block:: yaml

      rabbitmq:
        guest_enabled: True
