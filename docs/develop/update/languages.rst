Configure PHP, Node.js and Ruby
===============================

.. _php:

Configure PHP
-------------

The `PHP version <https://endoflife.date/php>`__ is set to the managed version for the Ubuntu release.

Configure Node.js
-----------------

The `default version <https://endoflife.date/nodejs>`__ is the latest LTS version, 22.

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
