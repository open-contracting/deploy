Configure Docker apps
=====================

.. note::

   This guide works with existing images. See the `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/docker/>`__ for how to build images from a Dockerfile using GitHub Actions.

.. seealso::

   :doc:`../../deploy/docker` and :doc:`../../maintain/docker`

The ``docker_apps`` state file performs common operations for apps deployed using Docker Compose. In your app's state file, include it with:

.. code-block:: yaml

   include:
     - docker_apps

If you already have an ``include`` state, add ``docker_apps`` to its list.

This will:

-  Install the Docker service

Configure Docker
----------------

.. admonition:: One-time setup

   Do this only once per server.

In the service's Pillar file, add, for example:

.. code-block:: yaml

   docker:
     user: deployer

This will:

-  Add a non-root user to the ``docker`` group

Configure Docker Compose
------------------------

.. admonition:: One-time setup

   Do this only once per server.

In the service's Pillar file, add, for example:

.. code-block:: yaml
   :emphasize-lines: 3-4

   docker:
     user: deployer
     docker_compose:
       version: 1.29.2

This will:

-  Install the Docker Compose binary

Add Docker Compose file
-----------------------

Create an ``{app}.yaml`` file in the `salt/docker_apps/files <https://github.com/open-contracting/deploy/tree/main/salt/docker_apps/files>`__ directory. For example:

.. code-block:: yaml

   services:
     web:
       image: "ghcr.io/open-contracting/myrepo:latest"
       restart: unless-stopped

Validate the file, for example:

.. code-block:: bash

   docker-compose config -q salt/docker_apps/files/redash.yaml

.. seealso::

   :ref:`django-configure`

.. admonition:: Stateful containers

   Containers are designed to be interrupted at any time, whereas stateful services like :doc:`PostgreSQL<postgres>` and :doc:`RabbitMQ<rabbitmq>` can fail in such conditions. Instead, run these on the host, where they are easier to operate with high reliability.

.. admonition:: One-off commands

   To run a one-off command, like a database migration, use `docker-compose run <https://docs.docker.com/compose/reference/run/>`__ on the command line, instead of creating a one-time container. See :doc:`../../deploy/docker` for examples.

   If you need to run a scheduled task in a cron job, use ``docker-compose run`` and redirect the output with ``2> /dev/null``, since there's no `quiet option <https://github.com/docker/compose/issues/6026>`__.

.. admonition:: Shared configuration

   To share configuration between services, you can use this pattern:

   .. code-block:: yaml

      x-shared: &shared
        image: "ghcr.io/open-contracting/myrepo:latest"
        restart: unless-stopped

      services:
        web:
          <<: *shared
        worker:
          <<: *shared
          command: "python -m worker"
          scale: 2

Reference:

-  `Compose specification <https://docs.docker.com/compose/compose-file/>`__
-  `Use Compose in production <https://docs.docker.com/compose/production/>`__

Configure Docker app
--------------------

In the service's Pillar file, add, for example:

.. code-block:: yaml

   docker_apps:
     myapp:
       target: mytarget
       env:
         MYVAR: myvalue

This will create files in the ``/data/deploy/mytarget`` directory:

-  ``docker-compose.yaml``, containing the same as the ``myapp.yaml`` file
-  ``.env``, containing the values under the ``env`` key

Reference:

-  `The ".env" file <https://docs.docker.com/compose/environment-variables/#the-env-file>`__
-  `Declare default environment variables in file <https://docs.docker.com/compose/env-file/>`__

Use host services
~~~~~~~~~~~~~~~~~

To connect to the host's services, like PostgreSQL or RabbitMQ, add to the Docker Compose file:

.. code-block:: yaml
   :emphasize-lines: 5-6

   services:
     web:
       image: "ghcr.io/open-contracting/myrepo:latest"
       restart: unless-stopped
       extra_hosts:
         - "host.docker.internal:host-gateway"

Then, under the ``env`` key in the service's Pillar file, use ``host.docker.internal`` instead of ``localhost``. For example:

.. code-block:: yaml
   :emphasize-lines: 5

   docker_apps:
     myapp:
       target: mytarget
       env:
         DATABASE_URL: "postgresql://user:pass@host.docker.internal:5432/name"

Reference:

-  `Networking overview <https://docs.docker.com/network/>`__
-  `Networking in Compose <https://docs.docker.com/compose/networking/>`__
-  `How to connect to the Docker host from inside a Docker container? <https://medium.com/@TimvanBaarsen/how-to-connect-to-the-docker-host-from-inside-a-docker-container-112b4c71bc66>`__

Map a port
~~~~~~~~~~

If the Dockerfile exposes a port, in the service's Pillar file, add, for example:

.. code-block:: yaml
   :emphasize-lines: 4

   docker_apps:
     myapp:
       target: mytarget
       port: 8001
       env:
         MYVAR: myvalue

This makes it easier for multiple Docker Compose files to refer to the port.

Then, in the Docker Compose file, add, for example:

.. code-block:: yaml
   :emphasize-lines: 5-6

   services:
     web:
       image: "ghcr.io/open-contracting/myrepo:latest"
       restart: unless-stopped
       ports:
         - {{ pillar.docker_apps.myapp.port }}:8000

Add a bind mount
~~~~~~~~~~~~~~~~

See the last step for `Bind mounts <https://ocp-software-handbook.readthedocs.io/en/latest/docker/dockerfile.html#bind-mounts>`__ in the Software Development Handbook.

Configure Apache
----------------

Apache is used as a reverse proxy to any web servers in the Docker containers. See :doc:`apache`. The configuration can simply be ``ProxyPass`` directives.
