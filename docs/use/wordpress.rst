WordPress
=========

The ``cms`` server hosts the ``corporate`` (`www.open-contracting.org <https://www.open-contracting.org>`__) and ``coalition`` (`www.open-spending.eu <https://www.open-spending.eu>`__) WordPress sites. To work on a site locally, you need its files and its database.

The sites' theme repositories contain a ``Makefile`` to load a local environment from these dumps:

-  `website <https://github.com/open-contracting-partnership/website>`__
-  `www.open-spending.eu <https://github.com/open-contracting-partnership/www.open-spending.eu>`__

.. _wordpress-snapshot:

Copy a site from the server
---------------------------

`script/snapshot-site <https://github.com/open-contracting/deploy/blob/main/script/snapshot-site>`__ dumps the database. For example:

.. code-block:: bash

   ./script/snapshot-site corporate
   ./script/snapshot-site coalition path/to/theme

Logs and Relevanssi search indexes are skipped, as a local site regenerates or doesn't need them. Pass ``--all-tables`` for a complete copy.

Pass ``--files`` to download the ``public_html`` directory as a ``.tar.gz`` file, or ``--rsync`` it as a directory, which is incremental and cheaper to repeat. ``wp-content/uploads`` is skipped; add it with ``--uploads``.

.. code-block:: bash

   ./script/snapshot-site corporate --files
   ./script/snapshot-site corporate --rsync --uploads

It connects as the site's own user, so anyone with deploy access can run it, and reads the database credentials from ``wp-config.php``. The dump uses ``--single-transaction``, to not lock tables on the live site. The archive is streamed, so the server needs no temporary space for a second copy of the site.

Load the site locally
~~~~~~~~~~~~~~~~~~~~~

The script prints the commands in this section, filled in for the site you copied. ``wp db export`` omits ``CREATE DATABASE``, so the database must exist first:

.. code-block:: bash

   mysql -e 'CREATE DATABASE IF NOT EXISTS corporate_wp'
   gunzip -c corporate-snapshot/corporate_wp.sql.gz | mysql corporate_wp

The database stores the site's URL and its absolute paths, so WordPress redirects to the production site until both are rewritten:

.. code-block:: bash

   wp search-replace 'https://www.open-contracting.org' 'http://localhost:8090' --all-tables
   wp search-replace '/home/corporate/public_html' "$(pwd)" --all-tables

.. note::

   The snapshot includes ``wp-config.php``, whose credentials are for the server's database. Point it at your local database before loading the site.

Download a backup instead
-------------------------

Use a backup to recover a deleted file or to see a site as it was, rather than as it is. Backups run daily. (The bucket name is narrower than its contents.)

.. code-block:: bash

   export AWS_DEFAULT_REGION=eu-west-2

   aws s3 ls s3://ocp-coalition-backup/database/
   aws s3 ls s3://ocp-coalition-backup/site/

Databases are named ``{timestamp}_{database}.sql.gz``. Site files are named after the directory, with non-alphanumeric characters replaced by underscores. For example:

.. code-block:: none

   database/20260827T044506Z_corporate_wp.sql.gz
   site/home_corporate_public_html_backup_20260827T041526Z.tar.gz

To download the most recent of each:

.. code-block:: bash

   latest() { aws s3 ls "s3://ocp-coalition-backup/$1/" | awk -v p="$2" '$4 ~ p {print $4}' | sort | tail -1; }

   aws s3 cp "s3://ocp-coalition-backup/database/$(latest database corporate_wp)" .
   aws s3 cp "s3://ocp-coalition-backup/site/$(latest site home_corporate)" .

The ``corporate`` site tarball is about 5 GB. If you only need the database, download that alone.
