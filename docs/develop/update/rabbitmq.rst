Configure RabbitMQ
==================

Add service accounts
--------------------

To configure the message broker for an application:

#. Add a user, in a private Pillar file, replacing ``PASSWORD`` with a `strong password <https://www.lastpass.com/features/password-generator>`__ (uncheck *Symbols*) and ``USERNAME`` with a recognizable username:

   .. code-block:: yaml

      rabbitmq:
        users:
          USERNAME:
            password: "PASSWORD"

#. If the user is an administrative or service account, allow configure and write `operations <https://www.rabbitmq.com/access-control.html#authorisation>`__ on all resources:

   .. code-block:: yaml
      :emphasize-lines: 5

      rabbitmq:
        users:
          USERNAME:
            password: "PASSWORD"
            write: true

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

   **Do not do this if a management interface port (15671, 15672) is open or proxied.**

.. _rabbitmq-proxy:

Proxy management interface
--------------------------

The `RabbitMQ management plugin <https://www.rabbitmq.com/management.html>`__ is enabled by default.

The management interface can be accessed at all times by :ref:`using an SSH tunnel<rabbitmq-ssh-tunnel>`.

To proxy traffic through :doc:`Apache<apache>` instead, add to your service's Pillar file, replacing ``SERVERNAME``:

.. code-block:: yaml

   apache:
     public_access: True
     sites:
       rabbitmq:
         configuration: rabbitmq
         servername: SERVERNAME
