Create a server
===============

A server is created either when a service is moving to a new server, or when a service is being introduced.

As with other deployment tasks, do the :ref:`setup tasks<generic-setup>` before (and the :ref:`cleanup tasks<generic-cleanup>` after) the steps below.

1. Create the new server
------------------------

Create the server via the :ref:`host<hosting>`'s interface.

Linode
~~~~~~

#. `Log into Linode <https://login.linode.com/>`__
#. Click *Create Linode*

   #. Set *Images* to "Ubuntu 20.04 LTS"
   #. Set *Region* to *London UK*
   #. Select a *Linode Plan*
   #. Set *Linode Label* to the server's FQDN (e.g. ``ocp12.open-contracting.org``)
   #. Set *Add Tags* to either *Production* or *Development*
   #. Set *Root Password* to a `strong password <https://www.lastpass.com/password-generator>`__
   #. Check *Backups*
   #. Click *Create Linode* and wait a few minutes for the server to power on

#. From the `Linodes <https://cloud.linode.com/linodes>`__ list:

   #. Click on the label for the new server
   #. Click *Power Off* and wait for the server to power off
   #. On the *Storage* tab:

      #. Resize the "Swap Image" disk to the appropriate size

         The swap size should be at most 200% of RAM and:

         -  If RAM is less than 2 GB: at least 100% of RAM
         -  If RAM is less than 32 GB: at least 50% of RAM
         -  Otherwise, at least 16 GB or 25% of RAM, whichever is greater

         If the swap size is too small, a swap file is `configured <https://github.com/open-contracting/deploy/blob/main/salt/core/swap.sls>`__ by Salt.

      #. Rename the "Swap Image" disk to "### MB Swap Image"
      #. Resize the "Ubuntu 20.04 LTS Disk" disk to the desired size (recommended minimum 20 GB / 20480 MB)

   #. On the *Configurations* tab:

      #. Click *Edit* for the "My Ubuntu 20.04 LTS Disk Profile" (or similar) config
      #. Uncheck *Auto-configure networking*
      #. Click *Save Changes*

   #. Click *Power On*
   #. Copy *SSH Access* to your clipboard

#. Open a support ticket with Linode to add the new server to our ``2a01:7e00:e000:02cc::/64`` IPv6 range.

   .. note::

      Linode can take a day to close the ticket. In the meantime, proceed with the instructions below. Once the ticket is closed, add the IPv6 address to the :doc:`network configuration<../develop/update/netplan>`.

Hetzner
~~~~~~~

.. note::

   Hetzner dedicated servers are physical servers, and are commissioned to order. Pay attention to any wait times displayed, as some servers may not be available for several days.

#. Go to `Hetzner <https://www.hetzner.com/?country=us>`__
#. Click the *Dedicated* menu to browser for a suitable server
#. Click the *Order* button for the chosen server

   #. Set *Server Location* (no issues to date with the lowest price option)
   #. Set *Operating System* to "Ubuntu 18.04 LTS - minimal".

      .. note::

         If Ubuntu isn't an option, you will need to :ref:`install-ubuntu` after these steps.

   #. Set *Drives* as needed
   #. Click the *Order Now* button
   #. In the *Server Login Details* panel, set *Type* to "Public key" and enter your public SSH key

      .. note::

         This adds your public SSH key to ``/root/.ssh/authorized_keys``.

   #. Click the *Save* button
   #. Review the order and click the *Checkout* button
   #. If prompted, login using OCP's credentials
   #. Check the "I have read your Terms and Conditions as well as your Privacy Policy and I agree to them." box
   #. Click the *Order in obligation* button

#. Wait to be notified via email that the server is ready.

.. _install-ubuntu:

Install Ubuntu
^^^^^^^^^^^^^^

If Ubuntu wasn't an option, follow these steps to install Ubuntu:

#. Activate and load the `Rescue System <https://wiki.hetzner.de/index.php/Hetzner_Rescue-System/en>`__, if not already loaded.
#. Connect to the server as the ``root`` user using the password provided when activating the Rescue System.
#. Test the server hardware:

   #. Test the drives. The SMART values to check vary depending on the drive manufacturer. Ask a colleague if you need help.

      .. code-block:: bash

         smartctl -t long /dev/<device>
         smartctl -a /dev/<device>

   #. Test the hardware RAID controller, if there is one. The software to do so varies depending on the RAID controller. Ask a colleague if you need help.

#. Run the pre-installed `Hetzner OS installer <https://github.com/hetzneronline/installimage>`__ (`see documentation <https://wiki.hetzner.de/index.php/Installimage/en>`__) and accept the defaults, unless stated otherwise below:

   .. code-block:: bash

      installimage

   #. Select "Ubuntu 18.04 - minimal"

   #. The installer opens a configuration file.

      #. Set ``DRIVE1``, ``DRIVE2``, etc. to the drives you want to use (`see documentation <https://wiki.hetzner.de/index.php/Installimage/en#Drives>`__). You can identify drives with the ``smartctl`` command. If you ordered two large drives for a server that already includes two small drives, you might only set the large drives. For example:

         .. code-block:: none

            DRIVE1 /dev/sdb
            DRIVE2 /dev/sdd

      #. Set ``SWRAIDLEVEL 1``
      #. Set the hostname (see more under :ref:`create-dns-records`). For example:

         .. code-block:: none

            HOSTNAME ocp##.open-contracting.org

      #. Create partitions. Set the ``swap`` partition size according to the comments in `swap.sls <https://github.com/open-contracting/deploy/blob/main/salt/core/swap.sls>`__. For example:

         .. code-block:: none

            PART swap swap 16G
            PART /boot ext2 1G
            PART / ext4 all

   #. Press ``F2`` to save

   #. Confirm that you want to overwrite the drives, when prompted

#. Reboot the server:

   .. code-block:: bash

      reboot

.. _create-dns-records:

2. Create DNS records
---------------------

Hostnames follow the format ``ocp##.open-contracting.org`` (ocp01, ocp02, etc.). Increment the number by 1 for each new server, to ensure the hostname is unique and used only once. To determine the greatest number, refer to GoDaddy and the `salt-config/roster <https://github.com/open-contracting/deploy/blob/main/salt-config/roster>`__ file.

#. Login to `GoDaddy <https://sso.godaddy.com>`__
#. If access was delegated, open `Delegate Access <https://account.godaddy.com/access>`__ and click the *Access Now* button
#. Open `DNS Management <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__ for open-contracting.org
#. Add an A record for the hostname:

   #. Click *ADD*
   #. Select "A" from the *Type* dropdown
   #. Enter the hostname in *Host* (``ocp42``, for example)
   #. Enter the IPv4 address in *Points to*
   #. Leave *TTL* at the 1 Hour default
   #. Click the *Save* button

#. If the server has an IPv6 address, add an AAAA record for the hostname:

   #. Click *ADD*
   #. Select "AAAA" from the *Type* dropdown
   #. Enter the hostname in *Host* (``ocp42``, for example)
   #. Enter the IPv6 address in *Points to*
   #. Leave *TTL* at the 1 Hour default
   #. Click the *Save* button

3. Apply core changes
---------------------

#. Connect to the server as the ``root`` user using SSH, and change its password, using the ``passwd`` command. Use a `strong password <https://www.lastpass.com/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account.

   .. note::

      The root password is needed if you can't login via SSH (for example, due to a broken configuration). For Bytemark, open the `panel <https://panel.bytemark.co.uk/servers>`__, click the server's *Console* button, and login.

#. Add a target to the ``salt-config/roster`` file in this repository. Name the target after the service.

   - If the service is moving to a new server, you can use the old target's name for the new target, and add a ``-old`` suffix to the old target's name.
   - If the service is an instance of `CoVE <https://github.com/OpenDataServices/cove>`__, add a ``cove-`` prefix.
   - If the environment is development, add a ``-dev`` suffix.
   - Do not include an integer suffix in the target name.

   .. note::

      If the DNS records have not yet propagated, you can temporarily use the server's IP address instead of its hostname in the roster.

#. :doc:`../develop/update/netplan`.

#. Run the `onboarding <https://github.com/open-contracting/deploy/blob/main/salt/onboarding.sls>`__ and core state files, which upgrade all packages, configure the hostname and apply the base configuration.

   .. code-block:: bash

      salt-ssh --log-level=trace TARGET state.apply 'onboarding,core*'

   .. note::

      This step takes 3-4 minutes, so ``--log-level=trace`` is used to show activity.

#. `Reboot the server <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.system.html#salt.modules.system.reboot>`__:

   .. code-block:: bash

      ./run.py TARGET system.reboot

.. note::

   The hostname configured in this step and the DNS records created in the previous step are relevant to:

   -  verify that an email message has a legitimate source (for example, from cron jobs)
   -  communicate between servers (for example, for database replication)
   -  identify servers in human-readable way

   As such, DNS records that match the hostname must be maintained, until the server is decommissioned.

4. Deploy the service
---------------------

#. If the service is being introduced, add the target to the ``salt/top.sls`` and ``pillar/top.sls`` files, and include any new state or Pillar files you authored for the service.

#. If the service is moving to the new server, update occurrences of the old server's hostname and IP address. (In some cases described in the next step, you'll need to deploy the related services.)

#. :doc:`Deploy the service<deploy>`.

Some IDs might fail (`#156 <https://github.com/open-contracting/deploy/issues/156>`__):

-  ``uwsgi``, using the ``service.running`` function. If so, run:

   .. code-block:: bash

      ./run.py TARGET service.restart uwsgi

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
#. Update the IP addresses in the ``pillar/cove.sls`` file, and deploy the ``cove-*`` services
#. Optionally, copy the Apache log files

For Kingfisher servers (instructions are incomplete):

#. Update the IP addresses in the ``pillar/tinyproxy.sls`` file, and deploy the ``docs`` service

For Redash servers, see :doc:`redash`.

If the server runs a database like PostgreSQL or Elasticsearch, copy the database.

6. Update external services
---------------------------

#. :doc:`Add the server to Prometheus<prometheus>`
#. Add (or update) the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__, for example:

   #. Click *ADD*
   #. Select "CNAME" from the *Type* dropdown
   #. Enter the public hostname in *Host* (``standard``, for example)
   #. Enter the internal hostname in *Points to* (``ocp42.open-contracting.org``, for example)
   #. Leave *TTL* at the 1 Hour default
   #. Click the *Save* button

#. Add (or update) the service's row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Add (or update) managed passwords, if appropriate
#. Contact Dogsbody Technology Ltd to set up maintenance (`see readme <https://github.com/open-contracting/dogsbody-maintenance#readme>`__)
#. :doc:`Delete the old server<delete_server>`

If the service is being introduced:

#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__
#. Add the embed code for `Fathom Analytics <https://app.usefathom.com/>`__, if appropriate

If the service uses a new domain name:

#. Add the domain to `Google Webmaster Central <https://www.google.com/webmasters/verification/home?hl=en>`__
#. Add the domain to `Google Search Console <https://search.google.com/search-console>`__
