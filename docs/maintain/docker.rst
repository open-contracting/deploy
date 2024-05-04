Maintain Docker
===============

Get basic information:

.. code-block:: bash

   docker system info

.. tip::

   To troubleshoot ``docker compose`` commands, add the ``--verbose`` option.

Reference: `Overview of docker compose CLI <https://docs.docker.com/compose/reference/>`__

Review log files
----------------

Run, replacing ``CONTAINER``:

.. code-block:: bash

   docker compose logs -f -t CONTAINER

Open a shell
------------

Open a Bash shell, for example:

.. code-block:: bash

   docker compose run --rm --name my-app-shell static bash

Open a Python shell, for example:

.. code-block:: bash

   docker compose run --rm --name my-app-shell cron python manage.py shell

`Our Python projects <https://ocp-software-handbook.readthedocs.io/en/latest/python/settings.html#word-choice>`__ follow a ``LOG_LEVEL`` environment variable, which you can set with ``-e LOG_LEVEL=DEBUG``, for example.

Check project usage
-------------------

Show containers' status:

.. code-block:: bash

   docker compose ps

Show containers' processes:

.. code-block:: bash

   docker compose top

Check system-wide usage
-----------------------

Check drive usage:

.. code-block:: bash

   docker system df

List containers, images, networks and volumes:

.. code-block:: bash

   docker container ls -a
   docker image ls -a
   docker network ls
   docker volume ls

Inspect a volume, replacing ``VOLUME``:

.. code-block:: bash

   docker volume inspect VOLUME

List a volume's data, replacing ``VOLUME``:

.. code-block:: bash

   ls /var/lib/docker/volumes/VOLUME/_data/*

Prune objects
-------------

List dangling objects:

.. code-block:: bash

   docker image ls --filter dangling=true
   docker volume ls --filter dangling=true

Prune unused objects:

.. code-block:: bash

   docker system prune

Remove unused images in addition to dangling ones:

.. code-block:: bash

   docker system prune -a

Reference: `Prune unused Docker objects <https://docs.docker.com/config/pruning/>`__
