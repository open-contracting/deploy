Ubuntu Pro
==========

`Ubuntu Pro <https://ubuntu.com/pro>`__ is an enterprise subscription from Canonical Ltd that provides (among other features) extended security support after the standard end-of-life date. This is also referred to as Extended Security Maintenance (ESM).

.. note::

   `Salt does not support ESM <https://docs.saltproject.io/salt/install-guide/en/latest/topics/salt-supported-operating-systems.html#ubuntu>`__.

Installation
------------

#. `Purchase an Ubuntu Pro license <https://ubuntu.com/pro/subscribe>`__ for *Physical servers with unlimited VMs* for the relevant Ubuntu version. A license cannot be purchased for VPS (like Linode).
#. :doc:`SSH<../use/ssh>` into the server as the ``root`` user.
#. Install the Ubuntu Pro Client.

   .. code-block:: bash

      apt install ubuntu-advantage-tools

#. Attach the licence key.

   .. code-block:: bash

      pro attach TOKEN

#. Disable advertisements:

   .. code-block:: bash

      pro config set apt_news=false
