Configure WordPress
===================

Apache
------

Follow the :doc:`apache` documentation, using the ``wordpress`` configuration at the :ref:`apache-sites` step.

In the service's Pillar file, add, for example:

.. code-block:: yaml

   apache:
     public_access: True
     sites:
       coalition:
         configuration: wordpress
         servername: www.open-spending.eu
         serveraliases: ['open-spending.eu']
         context:
           user: coalition
           socket: /var/run/php/php-fpm-coalition.sock

.. _wordpress-mysql-php:

MySQL and PHP
-------------

Follow the :doc:`mysql` and :ref:`php` documentation.

.. note::

   `The official WordPress distribution only supports the MySQL and MariaDB database engines <https://codex.wordpress.org/Using_Alternative_Databases>`__.

PHP-FPM
-------

Configure `PHP-FPM <https://www.php.net/manual/en/install.fpm.php>`__ to correspond to the Apache configuration. For example:

.. code-block:: yaml

   phpfpm:
     sites:
       coalition:
         configuration: default
         context:
           user: coalition
           listen_user: www-data
           socket: /var/run/php/php-fpm-coalition.sock

.. note::

   You can create a custom configuration, if needed.

WordPress
---------

.. note::

   Salt contains `WordPress states <https://docs.saltproject.io/en/latest/ref/states/all/salt.states.wordpress.html>`__, but they are limited. Also, WordPress is often deployed by copying files, rather than via fresh installs.

#. Configure `WP-CLI <https://wp-cli.org>`__. In the service's Pillar file, add, for example:

   .. code-block:: yaml

      wordpress:
        cli_version: 2.7.1

#. :doc:`Deploy the service<../../deploy/deploy>`.
#. :doc:`Connect to the server<../../use/ssh>` as the WordPress user (e.g. ``coalition``).
#. Change to the ``public_html`` directory:

   .. code-block:: bash

      cd ~/public_html

#. Download WordPress:

   .. code-block:: bash

      wp core download --locale=en_US

#. Create the ``wp-config.php`` file, and configure the database connection, to correspond to the :ref:`MySQL configuration<wordpress-mysql-php>`. For example:

   .. code-block:: bash

      wp config create --dbname=DBNAME --dbuser=USERNAME --dbpass=PASSWORD

#. Set `WP_AUTO_UPDATE_CORE <https://developer.wordpress.org/advanced-administration/upgrade/upgrading/#constant-to-configure-core-updates>`__, to enable minor WordPress updates only.

   .. code-block:: bash

      wp config set WP_AUTO_UPDATE_CORE minor

#. Install WordPress, with a ``siteadmin`` user associated to ``sysadmin@open-contracting.org``. For example:

   .. code-block:: bash

      wp core install --url=www.open-spending.eu --title="www.open-spending.eu" --admin_user=siteadmin --admin_password=PASSWORD --admin_email=sysadmin@open-contracting.org --skip-email

#. Uninstall default plugins:

   .. code-block:: bash

      wp plugin uninstall hello

#. Add a `must-use plugin <https://developer.wordpress.org/advanced-administration/plugins/mu-plugins/>`__ to auto-update plugins for non-major versions only:

   .. note::

      `WP Rocket can't auto-update <https://docs.wp-rocket.me/article/1446-why-are-wp-rocket-auto-updates-disabled>`__.

   .. code-block:: bash

      mkdir -p wp-content/mu-plugins
      cat > wp-content/mu-plugins/opencontracting_auto_update_plugin.php <<'END'
      <?php
      // Auto-update a plugin if a new version is available and it is neither a new major version
      // nor a new minor version within major version zero.
      // https://core.trac.wordpress.org/ticket/51126
      function opencontracting_auto_update_plugin( $value, $item ) {
              // https://developer.wordpress.org/reference/functions/wp_plugin_directory_constants/
              $plugin_data = get_plugin_data( WP_PLUGIN_DIR . '/' . $item->plugin , false, false );
              // https://developer.wordpress.org/reference/functions/get_plugin_data/#return
              $old_version = explode( '.', $plugin_data['Version'] );
              $new_version = explode( '.', $item->new_version );
              // https://github.com/dependabot/fetch-metadata/blob/924483a/src/dependabot/update_metadata.ts#L77-L94
              if (
                      $old_version !== $new_version
                      && $old_version[0] === $new_version[0]
                      && ( $old_version[0] !== '0' || $old_version[1] === $new_version[1] )
              ) {
                      return true;
              }
              return $value;
      }
      // https://developer.wordpress.org/advanced-administration/upgrade/upgrading/#configuration-via-filters
      // https://developer.wordpress.org/reference/functions/add_filter/
      // https://developer.wordpress.org/reference/hooks/auto_update_type/
      add_filter( 'auto_update_plugin', 'opencontracting_auto_update_plugin', 10, 2 );
      END

#. If you have a custom theme, download and activate it. For example:

   .. code-block:: bash

      git -C wp-content/themes/ clone https://github.com/open-contracting-partnership/www.open-spending.eu.git
      wp theme activate www.open-spending.eu

Migration
~~~~~~~~~

When migrating domains or renaming themes, you might need to search and replace items in the database, using the `wp search-replace <https://developer.wordpress.org/cli/commands/search-replace/>`__ command.

#. Run the command with the ``--dry-run`` flag, for example:

   .. code-block:: bash

      wp search-replace --report-changed-only --all-tables --precise --log=/tmp/wp-search-replace.log --dry-run 'open-spedning-coalition' 'www.open-spending.eu'

#. Read the log file to check that no undesired replacements will be made:

   .. code-block:: bash

      less /tmp/wp-search-replace.log

#. Run the command without the ``--dry-run`` flag.

Strings to replace might include:

-  Developer email addresses
-  Domain names
-  Theme names
-  File paths

If the site uses these plugins, perform these operations to remove old items in the database:

-  `Rank Math <https://rankmath.com>`__: *Status & Tools* menu item > *Database Tools* tab > Click the *Delete Internal Links* and *Clear 404 Log* buttons.
-  `WordFence <https://www.wordfence.com>`__: *Scan* menu item -> Click the *START NEW SCAN* button. You can also manually delete rows from the ``wp_wfhits`` and ``wp_wflogins`` tables.
