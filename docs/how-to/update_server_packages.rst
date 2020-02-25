Update Server Packages
======================

Our servers run Ubuntu Linux.

Our servers have automatic unattended upgrades turned on for `security updates <https://usn.ubuntu.com/>`__. Some servers have auto reboot turned on and some don't. Normally dev/staging servers have it turned on and live servers have it turned off.

This still leaves some packages to be installed by hand, and some servers to be rebooted by hand. We follow this procedure regularly to do this.


Setup
-----

#. :ref:`Get the deploy token<get-deploy-token>`
#. :ref:`Update the deploy repositories<update-deploy-repositories>`
#. :ref:`Check if any spiders are running (A special step for Kingfisher)<check-if-spiders-are-running>`

Try and not upgrade Kingfisher when any work is running on that server.

For only running commands on some servers, you can obtain up to date server names by looking in ``salt-config/roster``.

List upgrades
-------------

For all servers:

.. code-block:: bash

    salt-ssh '*' pkg.list_upgrades dist=True refresh=True

To only run on some servers:

.. code-block:: bash

    salt-ssh -L ocds-docs-staging,ocds-docs-live pkg.list_upgrades dist=True refresh=True

This will list the upgrades that will be performed.

These can be checked against online sources. For instance there may be a known current Linux issue that you want to check is being dealt with.

Upgrade packages
----------------

For all servers:

.. code-block:: bash

    salt-ssh '*' pkg.upgrade dist=True refresh=True

To only run on some servers:

.. code-block:: bash

    salt-ssh -L ocds-docs-staging,ocds-docs-live pkg.upgrade dist=True refresh=True

Reboot if needed
----------------

To see which servers need to be rebooted:

.. code-block:: bash

    salt-ssh '*' file.file_exists /var/run/reboot-required


Create a list of only the servers that need rebooting (having double checked the special note about Kingfisher above) and run:

.. code-block:: bash

    salt-ssh -L ocds-docs-staging,ocds-docs-live system.reboot

Note that sometimes systemd will shutdown before salt gets confirmation. In this case the salt-ssh command will hang. Simply wait 30 seconds and stop it.

To check the reboots were done and the servers have restarted with no problems, run the ``file.file_exists`` command again and make sure they are all False.

Cleanup
-------

#. :ref:`Release the deploy token, noting which servers were rebooted in the token history<get-deploy-token>`

