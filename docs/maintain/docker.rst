Maintain Docker
===============

Get basic information:

.. code-block:: bash

   docker system info

Check usage
-----------

Check drive usage:

.. code-block:: bash

   docker system df

List containers, images, networks and volumes:

.. code-block:: bash

   docker container ls -a
   docker image ls -a
   docker network ls
   docker volume ls

List a volume's data, replacing ``VOLUME``:

.. code-block:: bash

   ls /var/lib/docker/volumes/VOLUME/_data/*

Prune objects
-------------

List dangling objects:

.. code-block:: bash

   docker image ls --filter dangling=true
   docker volume ls --filter dangling=true

.. code-block:: bash

   docker system prune

Remove unused images in addition to dangling ones:

.. code-block:: bash

   docker system prune -a

Reference: `Prune unused Docker objects <https://docs.docker.com/config/pruning/>`__
