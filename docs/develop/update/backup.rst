Configure backups
=================

.. seealso::

   -  :ref:`PostgreSQL backups<pg-setup-backups>`
   -  :ref:`MySQL backups<mysql-backups>`
   -  :doc:`Testing backups<../../maintain/backup>`

#. Create and configure an :ref:`S3 backup bucket<aws-s3-bucket>`
#. Configure the :doc:`AWS CLI<awscli>`
#. In the server's Pillar file, set ``backup.location`` to a bucket and prefix, and ``backup.directories`` to a dict of paths without values. You can annotate what a path must match, for example:

   .. code-block:: yaml

      backup:
        location: ocp-coalition-backup/site
        directories:
          # Must match directory in coalition/init.sls.
          /home/coalition/public_html/:

#. :doc:`Deploy the server<../../deploy/deploy>`

Sync Directory
--------------

.. note::

   Sync is used for Disaster Recovery, this is not a true, immutable backup.

#. Create and configure an :ref:`S3 backup bucket<aws-s3-bucket>`
#. Configure the :doc:`AWS CLI<awscli>`
#. In the server's Pillar file, set ``sync.location`` to a bucket and prefix, and ``sync.directories`` to a dict of paths without values. You can annotate what a path must match, for example:

   .. code-block:: yaml

      backup:
        location: ocp-registry-backup/file-sync
        directories:
          /data/storage/exporter:

#. :doc:`Deploy the server<../../deploy/deploy>`
