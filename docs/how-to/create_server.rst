Create a server
===============

A server is created either when a service is moving to a new server, or when a service is being introduced.

Setup
-----

#. :ref:`Get the deploy token<get-deploy-token>`
#. Create the server via the :ref:`host<hosting>`'s interface (below)

Create the server
-----------------

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

Deploy the service
------------------

#. Connect to the server over SSH

   #. Change the password of the root user
   #. Install packages for Agentless Salt:

      .. code-block:: bash

         apt-get install python-concurrent.futures python-msgpack

#. Update this repository

   #. Add the server to ``salt-config/roster``, using the hostname from above
   #. Add a target to ``salt/top.sls``, if necessary, and include the ``prometheus-client-apache`` state
   #. Add a target to ``pillar/top.sls``, if necessary
   #. Add any states, if necessary
   #. If a service is moving to the new server, update occurrences of the old server's hostname and IP address, as needed

#. `Upgrade packages <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.upgrade>`__ (can be slow):

   .. code-block:: bash

      salt-ssh TARGET pkg.upgrade refresh=True dist_upgrade=True

#. `Reboot the server <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.system.html#salt.modules.system.reboot>`__:

   .. code-block:: bash

      salt-ssh TARGET system.reboot

#. :doc:`Deploy the service<deploy>` (can be slow)
#. :ref:`Release the deploy token<release-deploy-token>`

Update external services
------------------------

#. Add (or update) the service's job in ``salt/private/prometheus-server-monitor/conf-prometheus.yml``
#. Add (or update) the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Add (or update) the service's row on the *Services* sheet of the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Add (or update) managed passwords, if appropriate

If the service is being introduced:

#. Add its downtime monitor to `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__
#. Add the analytics tag for `Google Analytics <https://analytics.google.com>`__, if appropriate
