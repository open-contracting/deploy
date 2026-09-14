Configure WordPress
===================

Apache
------

Follow the :doc:`apache` documentation, using the ``wordpress`` configuration at the :ref:`apache-sites` step.

In the server's Pillar file, add, for example:

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

This will:

-  Enable the :ref:`proxy_fcgi<apache-modules>` Apache module
-  Install the PHP-FPM service
-  Create a ``/var/log/php-fpm/coalition/`` log directory
-  Create a ``/etc/php/-/fpm/pool.d/coalition.conf`` configuration file
-  Install PHP packages

The configuration file enables `log_errors <https://www.php.net/manual/en/errorfunc.configuration.php#ini.log-errors>`__ and sets `error_log <https://www.php.net/manual/en/errorfunc.configuration.php#ini.error-log>`__ to ``/var/log/php-fpm/coalition/coalition.log``.

Configure :doc:`logrotate<logs>` for the log files:

.. code-block:: yaml

   logrotate:
     conf:
       php-site-logs:
         source: php-site-logs
         context:
           php_version: '8.1'

.. note::

   You can create a custom configuration, if needed.

WordPress
---------

.. note::

   Salt contains `WordPress states <https://docs.saltproject.io/en/latest/ref/states/all/salt.states.wordpress.html>`__, but they are limited. Also, WordPress is often deployed by copying files, rather than via fresh installs.

#. Configure `WP-CLI <https://wp-cli.org>`__ and the site. In the server's Pillar file, add, for example:

   .. code-block:: yaml

      wordpress:
        cli_version: 2.7.1
        sites:
          coalition:
            database: coalition_wp
            cron:
              contact:
                - sysadmin@open-contracting.org

#. :doc:`Deploy the server<../../deploy/deploy>`.
#. :doc:`Connect to the server<../../use/ssh>` as the WordPress user (e.g. ``coalition``).
#. Change to the ``public_html`` directory:

   .. code-block:: bash

      cd ~/public_html

#. Download WordPress:

   .. code-block:: bash

      wp core download --locale=en_US

#. Create the ``wp-config.php`` file, and configure the database connection to correspond to the :ref:`MySQL configuration<wordpress-mysql-php>`. For example:

   .. code-block:: bash

      wp config create --dbname=DBNAME --dbuser=USERNAME --dbpass=PASSWORD

#. Install WordPress, creating a user for yourself. For example:

   .. code-block:: bash

      wp core install --url=www.open-spending.eu --title="www.open-spending.eu" --admin_user=jmckinney --admin_password=PASSWORD --admin_email=jmckinney@open-contracting.org --skip-email

#. Uninstall default plugins:

   .. code-block:: bash

      wp plugin uninstall hello

#. Install `Two Factor <https://wordpress.org/plugins/two-factor/>`__ (2FA is required for administrators by the ``require-two-factor`` must-use plugin):

   .. code-block:: bash

      wp plugin install two-factor --activate

#. Install `Sentry for WordPress <https://wordpress.org/plugins/wp-sentry-integration/>`__. Activation is optional, as it's loaded by the ``00-sentry`` must-use plugin.

   .. code-block:: bash

      wp plugin install wp-sentry-integration

#. Add or override any constants, setting values to strings of PHP source. (The constants under ``wordpress:constants`` in the ``pillar/cms.sls`` file are configured on every site.) For example:

   .. code-block:: yaml

      wordpress:
        sites:
          USERNAME:
            constants:
              WP_AUTO_UPDATE_CORE: 'false'


#. Create a project in `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__, and set its DSN in the site's private Pillar file:

   .. code-block:: yaml

      wordpress:
        sites:
          USERNAME:
            constants:
              WP_SENTRY_PHP_DSN: "'https://1234567890abcdef1234567890abcdef@o123456.ingest.sentry.io/1234567890123456'"

   .. note:: The SDK sends each event over HTTPS as the request ends, occupying a PHP-FPM worker until the send completes. ``WP_SENTRY_CLIENTBUILDER_CALLBACK`` caps each send at a second.

   .. tip:: To monitor browser JavaScript errors, create a new project, and set the ``WP_SENTRY_BROWSER_DSN`` constant.

#. Add any `must-use plugins <https://developer.wordpress.org/advanced-administration/plugins/mu-plugins/>`__, with any context they need. (The must-use plugins under ``wordpress:mu_plugins`` in the ``pillar/cms.sls`` file are installed on every site.) For example:

   .. code-block:: yaml

      wordpress:
        sites:
          USERNAME:
            mu_plugins:
              - fathom-analytics
            context:
              FATHOM_ANALYTICS_ID: ABCDEFGH

#. Schedule checks. Omit ``integrity`` if the site uses a security plugin's file scanner, and ``updates`` if an administrator updates plugins manually:

   .. code-block:: yaml

      wordpress:
        sites:
          USERNAME:
            checks:
              enabled:
                - integrity
                - updates
                - silent
              premium_plugins:
                - advanced-custom-fields-pro

   .. admonition:: Interpreting the emails it sends

      -  The ``integrity`` check lists core and plugin files that differ from wordpress.org's copy: modified, missing or added. A plugin that writes to its own directory can cause a false positive. Confirm changes before restoring files from a backup.
      -  wordpress.org has no copy of a premium plugin, so the ``integrity`` check instead lists the files that changed while the plugin's version didn't. It records the files of each new version in ``premium-plugin-checksums.json``, in the site's home directory.
      -  The ``updates`` check lists the updates that won't install automatically: a major version, if ``WP_AUTO_UPDATE_CORE`` is ``'minor'``; a plugin or theme whose auto-updates are off; and a version that requires a newer PHP version than the server runs.
      -  The ``silent`` check lists the plugins whose update API gave no answer, which can be due to an HTTP timeout, an expired license, or the plugin being closed on wordpress.org.

#. :doc:`Deploy the server<../../deploy/deploy>`.
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
