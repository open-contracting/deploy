Configure Node.js and Ruby
==========================

Configure Node.js
-----------------

In the service's Pillar file, add, for example:

.. code-block:: yaml

   nodejs:
     version: 16

.. _rvm:

Configure Ruby
--------------

`Ruby Version Manager (RVM) <https://rvm.io>`__ is used instead of `apt <https://ubuntu.com/server/docs/package-management>`__, to install any `version of Ruby <https://www.ruby-lang.org/en/downloads/releases/>`__.

In the service's Pillar file, add, for example:

.. code-block:: yaml

   rvm:
     default_version: 3.1.2
