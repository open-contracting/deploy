Configure backups
=================

.. seealso::

   -  :ref:`PostgreSQL backups<pg-setup-backups>`
   -  :ref:`MySQL backups<mysql-backups>`

#. Create and configure an :ref:`S3 backup bucket<aws-s3-bucket>`
#. Configure the :doc:`AWS CLI<awscli>`
#. In the server's Pillar file, set ``backup.location`` to a bucket and prefix, and ``backup.directories`` to a list of paths. You can annotate what a path must match, for example:

   .. code-block:: yaml

      backup:
        location: ocp-coalition-backup/site
        directories:
          # Must match directory in coalition/init.sls.
          - /home/coalition/public_html/

#. :doc:`Deploy the service<../../deploy/deploy>`
