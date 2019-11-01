Maintain a server
=================

Clean root user directory
-------------------------

#. Run:

   .. code-block:: bash
   
      salt-ssh '*' cmd.run 'ls'

#. Leave any ``post.install.log`` files
#. Delete any ``index.html*`` files (created by a developer running ``wget`` commands to e.g. test proxy settings)

Upgrade packages
----------------

All servers use the `unattended-upgrades package <https://help.ubuntu.com/lts/serverguide/automatic-updates.html>`__ for security updates.

To show the upgradable packages, run:

.. code-block:: bash

   salt-ssh '*' pkg.list_upgrades

Autoremove packages
-------------------

To show the packages that were automatically installed and are no longer required:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.autoremove list_only=True

To remove these, run:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.autoremove purge=True

To show the packages that were removed but not purged, run:

.. code-block:: bash

   salt-ssh '*' pkg.list_pkgs removed=True

Upgrade Ubuntu
--------------

To determine the current versions, run:

.. code-block:: bash

   salt-ssh '*' cmd.run 'lsb_release -a'
