Configure WordPress
===================

Apache
------

Follow the :doc:`Apache` documentation, using the ``wordpress`` configuration at the :ref:`apache-sites` step.

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

MySQL
-----

.. note::

   `The official WordPress distribution only supports the MySQL and MariaDB database engines <https://codex.wordpress.org/Using_Alternative_Databases>`__.

Follow the :doc:`MySQL` documentation.

PHP
---

The `default version <https://endoflife.date/php>`__ is 8.1.

To override the version, update the server's Pillar file:

.. code-block:: yaml

   php:
     version: '8.1'

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

#. :doc:`Deploy the service<deploy>`.

#. Connect to the server as the WordPress user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 ocp21.open-contracting.org:8255 || true
      ssh coalition@ocp21.open-contracting.org

#. Change to the ``public_html`` directory:

   .. code-block:: bash

      cd ~/public_html

#. Download WordPress:

   .. code-block:: bash

      wp core download --locale=en_US

#. Configure WordPress' database connection, to correspond to the MySQL configuration. For example:

   .. code-block:: bash

      wp core config --dbname=DBNAME --dbuser=USERNAME --dbpass=PASSWORD

#. Install WordPress, with a ``siteadmin`` user associated to ``sysadmin@open-contracting.org``. For example:

   .. code-block:: bash

      wp core install --url=www.open-spending.eu --title="www.open-spending.eu" --admin_user=siteadmin --admin_password=PASSWORD --admin_email=sysadmin@open-contracting.org --skip-email

#. Uninstall default plugins:

   .. code-block:: bash

      wp plugin uninstall hello

#. If you have a custom theme, download and activate it. For example:

   .. code-block:: bash

      git -C wp-content/themes/ clone git@github.com:open-contracting-partnership/www.open-spending.eu.git
      wp theme activate www.open-spending.eu
