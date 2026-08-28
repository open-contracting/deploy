WordPress
=========

The ``cms`` server hosts the ``corporate`` (`www.open-contracting.org <https://www.open-contracting.org>`__) and ``coalition`` (`www.open-spending.eu <https://www.open-spending.eu>`__) WordPress sites. To work on a site locally, you need its files and its database.

The sites' theme repositories contain a ``Makefile`` to load a local environment from these dumps:

-  `website <https://github.com/open-contracting-partnership/website>`__
-  `www.open-spending.eu <https://github.com/open-contracting-partnership/www.open-spending.eu>`__

.. _wordpress-snapshot:

Copy a site from the server
---------------------------

`script/snapshot-site <https://github.com/open-contracting/deploy/blob/main/script/snapshot-site>`__ dumps the database:

.. code-block:: bash

   ./script/snapshot-site corporate
   ./script/snapshot-site coalition ~/Sites/open-spending

Search indexes and logs are skipped, as a local site regenerates or doesn't need them: ``relevanssi`` alone is 124 MB on ``corporate``. Pass ``--all-tables`` for a complete copy.

Add ``--files`` for ``public_html`` as a ``.tar.gz``, or ``--rsync`` for a directory, which is incremental and so cheaper to repeat. ``wp-content/uploads`` is skipped either way, being 4.9 GB on ``corporate``; add it with ``--uploads``.

.. code-block:: bash

   ./script/snapshot-site corporate --files
   ./script/snapshot-site corporate --rsync --uploads

It connects as the site's own user, so anyone with deploy access can run it, and reads the database credentials from ``wp-config.php``. The dump uses ``--single-transaction``, so it doesn't lock tables on the live site. The archive is streamed, so the server needs no temporary space for a second copy of the site.

.. note::

   This replaces WP Migrate, which Idea Bureau used to copy content to staging and local environments. Its saved profile exported the database only. The one difference is that WP Migrate ran from within ``wp-admin``, whereas this needs a shell and `WP-CLI <https://wp-cli.org>`__ locally.

Load the site locally
~~~~~~~~~~~~~~~~~~~~~

The script prints these commands, filled in for the site you copied. ``wp db export`` omits ``CREATE DATABASE``, so the database must exist first:

.. code-block:: bash

   mysql -e 'CREATE DATABASE IF NOT EXISTS corporate_wp'
   gunzip -c corporate-snapshot/corporate_wp.sql.gz | mysql corporate_wp

The database stores the site's URL and its absolute paths, so WordPress redirects to the production site until both are rewritten. WPML and ACF store values outside the core tables, so ``--all-tables`` is required. The paths appear within serialized values, which a plain SQL edit would corrupt, so use ``wp search-replace`` rather than ``sed``:

.. code-block:: bash

   wp search-replace 'https://www.open-contracting.org' 'http://localhost:8090' --all-tables
   wp search-replace '/home/corporate/public_html' "$(pwd)" --all-tables

.. note::

   The snapshot includes ``wp-config.php``, whose credentials are for the server's database. Point it at your local database before loading the site.

Download a backup instead
-------------------------

.. seealso:: :doc:`../maintain/backup` to test that backups are valid

Use a backup to recover a deleted file or to see a site as it was, rather than as it is. Backups run daily: files at 04:15 UTC, databases at 04:45 UTC.

.. code-block:: bash

   export AWS_DEFAULT_REGION=eu-west-2

   aws s3 ls s3://ocp-coalition-backup/database/
   aws s3 ls s3://ocp-coalition-backup/site/

Databases are named ``{timestamp}_{database}.sql.gz``. Site files are named after the directory, with non-alphanumeric characters replaced by underscores:

.. code-block:: none

   database/20260827T044506Z_corporate_wp.sql.gz
   site/home_corporate_public_html_backup_20260827T041526Z.tar.gz

To download the most recent of each:

.. code-block:: bash

   latest() { aws s3 ls "s3://ocp-coalition-backup/$1/" | awk -v p="$2" '$4 ~ p {print $4}' | sort | tail -1; }

   aws s3 cp "s3://ocp-coalition-backup/database/$(latest database corporate_wp)" .
   aws s3 cp "s3://ocp-coalition-backup/site/$(latest site home_corporate)" .

The ``corporate`` site tarball is about 5 GB. If you only need the database, download that alone.

.. note::

   Ask a :ref:`server manager<admin-access>` for the bucket's credentials. Each bucket has its own.
