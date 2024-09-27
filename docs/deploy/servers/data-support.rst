Data support
============

Create a data support main server
---------------------------------

Dependencies
~~~~~~~~~~~~

Tinyproxy
  #. Update the allowed IP addresses in the ``pillar/tinyproxy.sls`` file
  #. Deploy the ``docs`` service, when ready
Replica, if applicable
  #. Update the allowed IP addresses and hostname in the ``pillar/kingfisher_replica.sls`` file
  #. Deploy the ``kingfisher-replica`` service, when ready

Dependents
~~~~~~~~~~

#. Notify RBC Group of the new domain name for the new PostgreSQL server

Update Salt
~~~~~~~~~~~

.. seealso::

   :doc:`../create_server`

#. Check that ``docker.uid`` in the ``pillar/kingfisher_main.sls`` file matches the entry in the ``/etc/passwd`` file for the ``docker.user`` (``deployer``).
#. Comment out the state that creates the ``PELICAN_BACKEND_UPDATE_EXCHANGE_RATES`` cron job

Operating system
~~~~~~~~~~~~~~~~

#. Adjust reserved disk space to 1% for large disks:

   .. code-block:: bash

      tune2fs -m 1 /dev/md2

Docker apps
~~~~~~~~~~~

#. Run migrations for :doc:`Docker apps<../docker>` as the ``deployer`` user:

   .. code-block:: bash

      su - deployer

      cd /data/deploy/kingfisher-process/
      docker compose run --rm --name kingfisher-process-migrate cron python manage.py migrate

      cd /data/deploy/pelican-frontend/
      docker compose run --rm --name pelican-frontend-migrate cron python manage.py migrate

#. :doc:`Pull new images and start new containers for each Docker app<../docker>`.

Kingfisher Collect
~~~~~~~~~~~~~~~~~~

Once DNS has propagated, :ref:`update-spiders`.

Copy incremental data
^^^^^^^^^^^^^^^^^^^^^

#. :doc:`SSH<../../use/ssh>` into the new server as the ``incremental`` user:

   #. Generate an SSH key pair:

      .. code-block:: bash

         ssh-keygen -t rsa -b 4096 -C "incremental"

   #. Get the public SSH key:

      .. code-block:: bash

         cat ~/.ssh/id_rsa.pub

#. Add the public SSH key to the ``ssh.incremental`` list in the ``pillar/kingfisher_main.sls`` file:

   .. code-block:: yaml

      ssh:
        incremental:
          - ssh-rsa AAAB3N...

#. Change ``cron.present`` to ``cron.absent`` in the ``salt/kingfisher/collect/incremental.sls`` file.
#. :doc:`Deploy the old server and the new server<../deploy>`.
#. :doc:`SSH<../../use/ssh>` into the old server as the ``incremental`` user:

   #. Stop any processes started by the cron jobs.
   #. Dump the ``kingfisher_collect`` database:

      .. code-block:: bash

         pg_dump -U kingfisher_collect -h localhost -f kingfisher_collect.sql kingfisher_collect

#. :doc:`SSH<../../use/ssh>` into the new server as the ``incremental`` user.

   #. Copy the database dump from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:~/kingfisher_collect.sql .

   #. Load the database dump:

      .. code-block:: bash

         psql -U kingfisher_collect -h localhost -f kingfisher_collect.sql kingfisher_collect

   #. Copy the ``data`` directory from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:/home/incremental/data/ /home/incremental/data/

   #. Copy the ``logs`` directory from the old server. For example:

      .. code-block:: bash

         rsync -avz incremental@ocp04.open-contracting.org:/home/incremental/logs/ /home/incremental/logs/

#. Remove the public SSH key from the ``ssh.incremental`` list in the ``pillar/kingfisher_main.sls`` file.
#. Change ``cron.absent`` to ``cron.present`` in the ``salt/kingfisher/collect/incremental.sls`` file.
#. :doc:`Deploy the new server<../deploy>`.

Pelican backend
~~~~~~~~~~~~~~~

The initial migrations for Pelican backend are run by Salt.

#. Connect to the old server, and dump the ``exchange_rates`` table:

   .. code-block:: bash

      sudo -i -u postgres psql -c '\copy exchange_rates (valid_on, rates, created, modified) to stdout' pelican_backend > exchange_rates.csv

#. Copy the database dump to your local machine. For example:

   .. code-block:: bash

      rsync -avz root@ocp13.open-contracting.org:~/exchange_rates.csv .

#. Copy the database dump to the new server. For example:

   .. code-block:: bash

      rsync -avz exchange_rates.sql root@ocp23.open-contracting.org:~/

#. Populate the ``exchange_rates`` table:

   .. code-block:: bash

      psql -U pelican_backend -h localhost -c "\copy exchange_rates (valid_on, rates, created, modified) from 'exchange_rates.csv';" pelican_backend

Restore Salt
~~~~~~~~~~~~

#. Uncomment the state that creates the ``PELICAN_BACKEND_UPDATE_EXCHANGE_RATES`` cron job
#. :doc:`Deploy the new server<../deploy>`

Create a data support replica server
------------------------------------

#. Update ``postgres.replica_ipv4`` (and ``postgres.replica_ipv6``, if applicable) in the ``pillar/kingfisher_main.sls`` file.
