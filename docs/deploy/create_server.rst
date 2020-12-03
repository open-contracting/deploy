Create a server
===============

A server is created either when a service is moving to a new server, or when a service is being introduced.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

1. Create the new server
------------------------

Create the server via the :ref:`host<hosting>`'s interface.

Bytemark
~~~~~~~~

#. `Login to Bytemark <https://panel.bytemark.co.uk>`__
#. Click *Servers* and *Add a cloud server*

   #. Enter a *Name*
   #. Select a *Group* indicating the environment (*production* or *development*)
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
#. Click "Dedicated", and navigate to choose a suitable server for your application.
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

If you couldn't select Ubuntu above, follow these additional steps:

#. Activate and load the `Rescue System <https://wiki.hetzner.de/index.php/Hetzner_Rescue-System/en>`__, if not already loaded.
#. Connect to the server as the ``root`` user using the password provided when activating the Rescue System.
#. Test the server hardware:

   #. Test the drives. The SMART values to look for vary depending on the drive manufacturer. Ask a colleague if you need help.

      .. code-block:: bash

         smartctl -t long /dev/<device>
         smartctl -a /dev/<device>

   #. Test the hardware RAID controller, if there is one. The software to do so varies depending on the RAID controller. Ask a colleague if you need help.

#. Run the pre-installed `Hetzner OS installer <https://github.com/hetzneronline/installimage>`__ (`see documentation <https://wiki.hetzner.de/index.php/Installimage/en>`__) and accept the defaults, unless stated otherwise below:

   .. code-block:: bash

      installimage

   #. Select "Ubuntu 18.04 - minimal"

   #. The installer opens a configuration file with a number of install options.

      #. Set ``DRIVE1``, ``DRIVE2``, etc. to the drives you want to use (`see documentation <https://wiki.hetzner.de/index.php/Installimage/en#Drives>`__). You can identify drives with the ``smartctl`` command. If you ordered two large drives for a server that already includes two small drives, you might only set the large drives. For example:

         .. code-block:: none

            DRIVE1 /dev/sdb
            DRIVE2 /dev/sdd

      #. Set ``SWRAIDLEVEL 1``
      #. Set the hostname. For example:

         .. code-block:: none

            HOSTNAME ocp##.open-contracting.org

      #. Create partitions. Set the ``swap`` partition size according to the comments in `swap.sls <https://github.com/open-contracting/deploy/blob/master/salt/core/swap.sls>`__. For example:

         .. code-block:: none

            PART swap swap 16G
            PART /boot ext2 1G
            PART / ext4 all

   #. Press ``F2`` to save

   #. Confirm that you want to overwrite the drives, when prompted

#. Reboot the server:

   .. code-block:: bash

      reboot

2. Create DNS records
---------------------

#. Create a new hostname DNS entry in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__

Hostnames follow the format ``ocp##.open-contracting.org`` (ocp01, ocp02, etc.). Increment the number by 1 for each new server, to ensure the hostname is unique and used only once. To determine the greatest number, refer to GoDaddy or the `salt-config/roster <https://github.com/open-contracting/deploy/blob/master/salt-config/roster>`__ file.


3. Apply core changes
---------------------

#. Connect to the server as the ``root`` user using SSH, and change its password, using the ``passwd`` command. Use a `strong password <https://www.lastpass.com/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account.

.. note::

   The root password is needed if you can't login via SSH (for example, due to a broken configuration). For Bytemark, open the `panel <https://panel.bytemark.co.uk/servers>`__, click the server's *Console* button, and login.

#. Add a target to the ``salt-config/roster`` file in this repository, naming the target after the service. If the service is an instance of `CoVE <https://github.com/OpenDataServices/cove>`__, choose a target name starting with ``cove-``.

#. `Run the onboarding state file <https://github.com/open-contracting/deploy/blob/master/salt/onboarding.sls>__`

This state file ensures that the system is patched, configures the system hostname and applies the core salt configs.

Replace "ocpXX" with the hostname you set up in GoDaddy earlier.

  .. code-block:: bash
     
     salt-ssh TARGET state.apply onboarding pillar='{"host_id": "ocpXX"}'

#. `Reboot the server <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.system.html#salt.modules.system.reboot>`__:

   .. code-block:: bash

      salt-ssh TARGET system.reboot

4. Deploy the service
---------------------

   .. note::

      See docs here on how to :doc:`deploy services<deploy>`.

#. If the service is being introduced, add the target to ``salt/top.sls``, and include the ``prometheus-client-apache`` state file and any new state files you authored for the service.

   .. note::

      If a target expression (other than ``'*'``) matches the target, then skip this step. For example, ``'cove-*'`` matches ``cove-oc4ids``.

#. If the service is moving to the new server, update occurrences of the old server's hostname and IP address.

5. Migrate from the old server
------------------------------

#. :ref:`check-mail` for the root user
#. :ref:`Check the user directory<clean-root-user-directory>` of the root user

For Django application servers:

#. Copy the ``media`` directory and the ``db.sqlite3`` file from the app's directory
#. :ref:`check-mail` for the app user
#. Check the user directory of the app user
#. Optionally, copy the Apache and uWSGI log files

For OCDS documentation servers:

#. Copy the ``/home/ocds-docs/web`` directory
#. Update the IP addresses in the ``salt/apache/includes/cove.jinja`` file
#. Optionally, copy the Apache log files

For Redash servers, see :doc:`redash`.

If the server runs a database like PostgreSQL or Elasticsearch, copy the database.

6. Update external services
---------------------------

#. :doc:`Add the server to Prometheus<prometheus>`
#. Add (or update) the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__ (e.g. standard-search.open-contracting.org, postgres.open-contracting.org)
#. Add (or update) the service's row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Add (or update) managed passwords, if appropriate
#. Contact Dogsbody Technology Ltd to set up maintenance
#. :doc:`Delete the old server<delete_server>`

If the service is being introduced:

#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__
#. Add the analytics tag for `Google Analytics <https://analytics.google.com>`__, if appropriate
