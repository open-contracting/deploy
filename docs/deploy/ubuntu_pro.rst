Ubuntu Pro
==========

`Ubuntu Pro <https://ubuntu.com/pro>`__ is an enterprise subscription from Canonical Ltd that provides (among other features) extended security support after the standard end-of-life date, this is also referred to as Extended Security Maintenance (ESM).

.. note::

   `Salt Stack does not officially support ESM<https://docs.saltproject.io/salt/install-guide/en/latest/topics/salt-supported-operating-systems.html#ubuntu>`__, an end-of-life server will need removing from the Deploy repo regardless.

Installation
------------

#. Purchase an Ubuntu Pro licence from `Canonical <https://ubuntu.com/pro/subscribe>`__.
#. :doc:`SSH<../use/ssh>` into the server as the ``root`` user.
#. Install Ubuntu Pro software.

   .. code-block:: bash

      apt install ubuntu-advantage-tools

#. Attach licence key and configure.

   .. code-block:: bash

      pro attach <TOKEN>
      pro config set apt_news=false
