Create a server
===============

A server is created either when a service is moving to a new server, or when a service is being introduced.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

1. Create the server
--------------------

Create the server via the :ref:`host<hosting>`'s interface.

Bytemark
~~~~~~~~

#. `Login to Bytemark <https://panel.bytemark.co.uk>`__
#. Click "Servers" and "Add a cloud server"

   #. Enter a *Name*
   #. Select a *Group*
   #. Set *Location* to "York"
   #. Set *Server Resources*
   #. Set *Operating system* to "Ubuntu 18.04 (LTS)"
   #. Check *Enable backups*
   #. Set *Take a backup every* to 7 days
   #. Set *Starting on* to the following Thursday at a random time before 10:00 UTC
   #. Set *Root user has* to "SSH key (+ Password)" and enter your public key
   #. Click "Add this server"

#. Wait for the server to boot (a few minutes)
#. Click "Info" and copy the "Hostname/SSH"

2. Deploy the service
---------------------

#. Setup the server:

   #. Connect to the server over SSH
   #. Change the password of the root user, using the ``passwd`` command. Use a `strong password <https://www.lastpass.com/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account.
   #. Install packages for Agentless Salt:

      .. code-block:: bash

         apt-get install python-concurrent.futures python-msgpack

#. Update this repository:

   #. Add a target to ``salt-config/roster``, using the hostname from above. If the service is an instance of `CoVE <https://github.com/OpenDataServices/cove>`__, choose a target name starting with ``cove-live-``.

   #. If the service is being introduced, add the target to ``salt/top.sls``, and include the ``prometheus-client-apache`` state file and any new state files you authored for the service.

      .. note::

         If a target expression (other than ``'*'``) matches the target, then skip this step. For example, ``'cove-live*'`` matches ``cove-live-oc4ids``.

   #. If the service is being introduced, add the target to ``pillar/top.sls``, and include any new Pillar files you authored for the service.

      .. note::

         If a target expression (other than ``'*'``) matches the target, then skip this step. For example, ``'cove-live*'`` matches ``cove-live-oc4ids``.

   #. If the service is moving to the new server, update occurrences of the old server's hostname and IP address.

#. `Upgrade packages <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.upgrade>`__:

   .. code-block:: bash

      salt-ssh TARGET pkg.upgrade dist_upgrade=True

#. `Reboot the server <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.system.html#salt.modules.system.reboot>`__:

   .. code-block:: bash

      salt-ssh TARGET system.reboot

#. :doc:`Deploy the service<deploy>`

3. Update external services
---------------------------

#. :doc:`Add the server to Prometheus<prometheus>`
#. Add (or update) the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Add (or update) the service's row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Add (or update) managed passwords, if appropriate

If the service is being introduced:

#. Add its downtime monitor to `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__
#. Add the analytics tag for `Google Analytics <https://analytics.google.com>`__, if appropriate
