Configure backups
=================

.. seealso::

   -  :ref:`PostgreSQL backups<pg-setup-backups>`
   -  :ref:`MySQL backups<mysql-backups>`
   -  :doc:`Backup Testing</maintain/backup_testing>`

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
