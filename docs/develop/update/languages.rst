Configure PHP, Node.js and Ruby
===============================

.. _php:

Configure PHP
-------------

The `default version <https://endoflife.date/php>`__ is the latest Ubuntu-managed version, 8.1.

To override or lock the version, update the server's Pillar file:

.. code-block:: yaml

   php:
     version: '8.1'

Add, :doc:`Logrotate<logs>` configuration to manage PHP site logs:

.. code-block:: yaml

   logrotate:
     conf:
       php-site-logs:
         source:  php-site-logs
         context:
           php_version: '8.1'


Configure Node.js
-----------------

The `default version <https://endoflife.date/nodejs>`__ is the latest LTS version, 18.

To override or lock the version, update the server's Pillar file:

.. code-block:: yaml

   nodejs:
     version: 16

.. _rvm:

Configure Ruby
--------------

`Ruby Version Manager (RVM) <https://rvm.io>`__ is used instead of `apt <https://ubuntu.com/server/docs/package-management>`__, to install any `version of Ruby <https://www.ruby-lang.org/en/downloads/releases/>`__.

In the server's Pillar file, add, for example:

.. code-block:: yaml

   rvm:
     default_version: 3.1.2
