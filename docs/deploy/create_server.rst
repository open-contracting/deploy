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
#. Click *Servers* and *Add a cloud server*

   #. Enter a *Name*
   #. Select a *Group*
   #. Set *Location* to "York"
   #. Set *Server Resources*
   #. Set *Operating system* to "Ubuntu 18.04 (LTS)"
   #. Check *Enable backups*
   #. Set *Take a backup every* to 7 days
   #. Set *Starting on* to the following Thursday at a random time before 10:00 UTC
   #. Set *Root user has* to "SSH key (+ Password)" and enter your public key
   #. Click *Add this server*

#. Wait for the server to boot (a few minutes)
#. Click *Info* and copy the *Hostname/SSH*

.. note::

   The above steps add your public key to ``/root/.ssh/authorized_keys``. Related: :ref:`delete-authorized-key`.

Hetzner
~~~~~~~

.. note::

   Hetzner dedicated servers are physical servers, and are commissioned to order. Pay attention to any wait times displayed during the setup process, as some servers may not be available for several days.


#. Go to `Hetzner <https://www.hetzner.com/?country=us>`__
#. Click "Dedicated", and navigate to choose a suitable server for your application. So far, we've used EX-Line servers.
#. Click the "Order" button for the server that you've chosen

   #. Select a location; we've never had an issue with simply choosing the cheapest
   #. Select an operating system - "Ubuntu 18.04 LTS minimal"
   #. Select any additional storage required

#. Click "Order Now"
#. (optionally) Select "Public key" in the "Server Login Details" section, and paste your SSH key in; this will be added to /root/.ssh/authorized_keys
#. Click "Save"
#. Review the contents of the cart, then click "Checkout"
#. Log in using OCP's credentials. This will happen automatically if you're already logged into Hetzner services.
#. Check the "I have read your Terms and Conditions as well as your Privacy Policy and I agree to them." box
#. Click "Order in Obligation"
#. Wait until you receive an email notifying you that your server is ready, then proceed to deploying the service.

Some Hetzner servers only let you start on their recovery OS.

If you were not able to select Ubuntu above, you will need to follow these additional steps:

#. SSH into recovery image
#. Test the server hardware

  .. code-block:: bash

    smartctl -t long /dev/<device>
    smartctl -a /dev/<device>

#. Run the pre-installed `Hetzner OS installer <https://github.com/hetzneronline/installimage>`

   .. code-block:: bash

      installimage

   #. Follow the default installer prompts, unless specified.

   #. Select Ubuntu 18.04 - minimal

   #. The installer takes you to a configuration file with a number of install options.

      .. code-block:: none

         Set DRIVE1 and DRIVE2 etc to the physical disks you want
         ...
         SWRAIDLEVEL 1
         ...
         HOSTNAME <server hostname>
         ...
         PART swap swap 16G
         PART /boot ext2 1G
         PART / ext4 all

      For swap partition sizings refer to `salt coniguration<https://github.com/open-contracting/deploy/blob/master/salt/core/swap.sls>`.

   #. F2 # Save

   #. Overwrite drives

#. ``reboot``



2. Deploy the service
---------------------

#. Setup the server:

   #. Connect to the server over SSH
   #. Change the password of the root user, using the ``passwd`` command. Use a `strong password <https://www.lastpass.com/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account.

   .. note::

      The root password is needed if you can't login via SSH (for example, due to a broken configuration). For Bytemark, open the `panel <https://panel.bytemark.co.uk/servers>`__, click the server's *Console* button, and login.

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
#. Contact Dogsbody Technology Ltd to set up maintenance

If the service is being introduced:

#. Add its downtime monitor to `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__
#. Add the analytics tag for `Google Analytics <https://analytics.google.com>`__, if appropriate
