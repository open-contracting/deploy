Manage server packages
======================

All servers use the `unattended-upgrades package <https://help.ubuntu.com/lts/serverguide/automatic-updates.html>`__ for `security updates <https://usn.ubuntu.com/>`__. On development/staging servers, the package is configured to automatically reboot the server, according to the ``automatic_reboot`` variable in Pillar. For other servers, administrators perform the steps below on a weekly basis.

The commands below will run on all servers. To run on specific servers, replace ``'*'`` with either a glob pattern, like ``'cove-*'``, or with a comma-separated list using the ``-L`` flag, like ``-L kingfisher-process,kingfisher-replica``.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

1. List upgrades
----------------

.. code-block:: bash

   ./run.py '*' pkg.list_upgrades

Consider whether any upgrades are backwards-incompatible or have post-installation steps.

2. Upgrade packages
-------------------

.. code-block:: bash

    ./run.py '*' pkg.upgrade dist_upgrade=True

Monitor the output for relevant messages.

3. Reboot
---------

#. Find the servers that need to be rebooted:

   .. code-block:: bash

      ./run.py '*' file.file_exists /var/run/reboot-required

#. Reboot the servers that need to be rebooted. For example:

   .. code-block:: bash

      ./run.py -L server-one,server-two system.reboot

   Sometimes, this command hangs, waiting for a response from a server that is already shutting down. Simply wait 30 seconds and stop the command.

#. Check the servers have rebooted without issue:

   .. code-block:: bash

      ./run.py '*' file.file_exists /var/run/reboot-required

   All servers should respond with ``False``.
