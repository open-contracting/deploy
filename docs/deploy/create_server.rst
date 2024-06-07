Create a server
===============

.. note::

   Dogsbody Technology requires a lead time of six weeks for new servers. This means OCP typically creates new servers.

A server is created either when a service is moving to a new server, or when a service is being introduced.

As with other deployment tasks, do the :doc:`setup tasks<setup>` before the steps below.

1. Collect server requirements
------------------------------

-  Number of CPUs
-  GBs of RAM
-  GBs of disk
-  Whether Docker is used
-  What DNS to configure (e.g. subdomain)
-  What :doc:`services<../develop/update/index>` to configure

2. Create the new server
------------------------

Create the server via the :ref:`host<hosting>`'s interface.

.. tab-set::

   .. tab-item:: Linode
      :sync: linode

      #. `Log into Linode <https://login.linode.com/login>`__
      #. Click *Create Linode*

         #. Set *Images* to the latest Ubuntu LTS version
         #. Set *Region* to *London UK*
         #. Select a *Linode Plan*
         #. Set *Linode Label* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
         #. Set *Add Tags* to either *Production* or *Development*
         #. Set *Root Password* to a `strong password <https://www.lastpass.com/features/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account
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

               .. note::

                  If the swap image is too small, a swap file is `configured <https://github.com/open-contracting/deploy/blob/main/salt/core/swap.sls>`__ by Salt.

            #. Rename the "Swap Image" disk to "### MB Swap Image"
            #. Resize the "Ubuntu ##.04 LTS Disk" disk to the desired size (recommended minimum 20 GB / 20480 MB)

         #. On the *Configurations* tab:

            #. Click *Edit* for the "My Ubuntu ##.04 LTS Disk Profile" (or similar) configuration
            #. Uncheck *Auto-configure networking* (skip if configuring a non-OCP server)
            #. Click *Save Changes*

         #. Click *Power On*
         #. Copy *SSH Access* to your clipboard

      #. `Open a support ticket with Linode <https://cloud.linode.com/support/tickets>`__ to assign an IPv6 /64 block to the new server.

            Hello,

            Please assign an IPv6 /64 block to the server ocp##.open-contracting.org.

            Thank you,

         .. note::

            Linode can take a day to close the ticket. In the meantime, proceed with the instructions below. Once the ticket is closed, assign a specific address within the /64 block in the :doc:`network configuration<../develop/update/network>`.

      #. If using Docker, :ref:`configure an external firewall<docker-firewall>`.

   .. tab-item:: Hetzner Cloud
      :sync: hetzner-cloud

      #. Go to the `Hetzner Cloud Console <https://console.hetzner.cloud/projects>`__
      #. Click the *Default* project
      #. Click the *Add Server* button

         #. Click the *Falkenstein* location
         #. Click the *Ubuntu* image
         #. Select a *Type*
         #. Click the *Add SSH key* button

            #. Enter :ref:`your public SSH key<add-public-key>` in *SSH key*
            #. Enter your full name in *Name*
            #. Click the *Add SSH key* button

            .. note::

               This adds your public SSH key to ``/root/.ssh/authorized_keys``.

         #. Check the *Backups* box
         #. Enter the hostname in *Server name* (``ocp42``, for example)
         #. Click the *Create & Buy now* button

      #. If using Docker, :ref:`configure an external firewall<docker-firewall>`.

   .. tab-item:: Hetzner Dedicated
      :sync: hetzner-dedicated

      .. note::

         Hetzner dedicated servers are physical servers, and are commissioned to order. Pay attention to any wait times displayed, as some servers may not be available for several days.

      #. Go to `Hetzner <https://www.hetzner.com/?country=us>`__
      #. Click the *Dedicated* menu to browser for a suitable server
      #. Check the `Server Auction <https://www.hetzner.com/sb>`__ for a comparable server
      #. Click the *Order* button for the chosen server

         #. Set *Server Location* (no issues to date with the lowest price option)
         #. Set *Operating System* to the latest Ubuntu LTS version

            .. note::

               If Ubuntu isn't an option, you will need to install Ubuntu after these steps. Servers from the Server Auction are delivered in the `Hetzner Rescue System <https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/>`__.

         #. Set *Drives* as needed
         #. Click the *Order Now* button
         #. In the *Server Login Details* panel, set *Type* to "Public key" and enter :ref:`your public SSH key<add-public-key>`

            .. note::

               This adds your public SSH key to ``/root/.ssh/authorized_keys``.

         #. Click the *Save* button
         #. Review the order and click the *Checkout* button
         #. If prompted, login using OCP's credentials
         #. Check the "I have read your Terms and Conditions as well as your Privacy Policy and I agree to them." box
         #. Click the *Order in obligation* button

      #. Wait to be notified via email that the server is ready.

      .. tab-set::

         .. tab-item:: Install Ubuntu

            If Ubuntu wasn't an option, follow these steps to install Ubuntu:

            #. Activate and load the `Rescue System <https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/>`__, if not already loaded.
            #. Connect to the server as the ``root`` user using the password provided when activating the Rescue System.
            #. Test the server hardware:

               #. Test the drives. The SMART values to check vary depending on the drive manufacturer. Ask a colleague if you need help.

                  .. code-block:: bash

                     smartctl -t long /dev/<device>
                     smartctl -a /dev/<device>

               #. Test the hardware RAID controller, if there is one. The software to do so varies depending on the RAID controller. Ask a colleague if you need help.

            #. Run the pre-installed `Hetzner OS installer <https://github.com/hetzneronline/installimage>`__ (`see documentation <https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/>`__) and accept the defaults, unless stated otherwise below:

               .. code-block:: bash

                  installimage

               #. Select the latest Ubuntu LTS version.

               #. The installer opens a configuration file.

                  #. Set ``DRIVE1``, ``DRIVE2``, etc. to the drives you want to use (`see documentation <https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/#drives>`__). You can identify drives with the ``smartctl`` command. If you ordered two large drives for a server that already includes two small drives, you might only set the large drives. For example:

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

            #. If using Docker, :ref:`configure an external firewall<docker-firewall>`.

         .. tab-item:: Install Windows

            .. seealso::

               -  `Windows Server 2019 <https://docs.hetzner.com/robot/dedicated-server/windows-server/windows-server-2019/>`__
               -  `Installing Windows without KVM <https://community.hetzner.com/tutorials/install-windows>`__

   .. tab-item:: Azure
      :sync: azure

      .. seealso::

         -  `Pricing calculator <https://azure.microsoft.com/en-us/pricing/calculator/>`__, to estimate costs
         -  `Virtual machine series <https://azure.microsoft.com/en-gb/pricing/details/virtual-machines/series/>`__
         -  `Virtual machine sizes naming conventions <https://learn.microsoft.com/en-us/azure/virtual-machines/vm-naming-conventions>`__

      #. `Log into Azure <https://portal.azure.com>`__
      #. Click the *Virtual machines* icon
      #. Click the *Create* menu
      #. Click the *Azure virtual machine* menu item

         #. Set *Subscription* to "Microsoft Azure Sponsorship (4e98b5b1-1619-44be-a38e-90cdb8e4bc95)"
         #. Set `Resource group <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal>`__ to "default"
         #. Set *Virtual machine name* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
         #. Set *Region* to "(Europe) UK South" (or "(US) East US" or "(US) West US 2")
         #. Leave *Security type* as `Trusted launch virtual machines <https://learn.microsoft.com/en-ca/azure/virtual-machines/trusted-launch>`__
         #. Set *Image* to the latest Ubuntu LTS version
         #. Set *Size* to an appropriate size (e.g. ``B2s``) (Select *No grouping* when browsing)
         #. Set *Authentication type* to "Password"
         #. Set *Username* to "ocpadmin"
         #. Set *Password* to a `strong password <https://www.lastpass.com/features/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account

      #. Click the *Next : Disks >* button

         #. Change *OS disk size*, if appropriate

            .. seealso::

               `Expand virtual hard disks on a Linux VM <https://learn.microsoft.com/en-ca/azure/virtual-machines/linux/expand-disks?tabs=ubuntu>`__

         #. Set *OS disk type* to *Standard SSD* (or *Standard HDD* in development)
         #. Add additional disks, if appropriate:

            #. Click the *Create and attach a new disk* link
            #. Click the *Change size* link
            #. Set *Storage type* to "Standard SSD"
            #. Click the desired size
            #. Click the *OK* button

      #. Click the *Next : Networking >* button

         #. Set *Virtual network* to an appropriate name with a ``-vnet`` suffix (e.g. ``ocp42.open-contracting.org-vnet``)
         #. Set *Subnet* to *default (10.0.0.0/24)*
         #. Set *Public IP* to the server's FQDN (e.g. ``ocp42.open-contracting.org-ip``)
         #. If not using Docker, set *NIC network security group* to *None*
         #. If using Docker, set *NIC network security group* to *Advanced*

            #. Click the *Create new* link for *Configure network security group*
            #. Set *Name* to the server's FQDN with a ``-nsg`` suffix (e.g. ``ocp42.open-contracting.org-nsg``)
            #. Click the *+ Add an inbound rule* link, to produce rules matching the following:

               .. list-table::
                  :header-rows: 1

                  * - Source
                    - Service
                    - Destination port ranges
                    - Protocol
                    - Priority
                    - Name
                  * - Any
                    - SSH
                    - 22
                    - TCP
                    - 1000
                    - default-allow-ssh
                  * - Any
                    - HTTP
                    - 80
                    - TCP
                    - 1010
                    - AllowAnyHTTPInbound
                  * - Any
                    - HTTPS
                    - 443
                    - TCP
                    - 1020
                    - AllowAnyHTTPSInbound
                  * - Any
                    - Custom
                    - ``*``
                    - ICMP
                    - 1030
                    - AllowAnyICMPInbound
                  * - 139.162.253.17/32
                    - Custom
                    - 7231
                    - TCP
                    - 1040
                    - AllowPrometheusIPv4Inbound
                  * - 2a01:7e00::f03c:93ff:fe13:a12c/128
                    - Custom
                    - 7231
                    - TCP
                    - 1050
                    - AllowPrometheusIPv6Inbound

               .. Combining the Prometheus rules causes "Validation failed":
                  "All IP addresses or prefixes in the resource should belong to the same address family."

            #. Click the *OK* button

      #. Click the *Next : Management >* button

         #. Check the *Enable backup* box
         #. Set `Recovery Services vault <https://learn.microsoft.com/en-us/azure/backup/backup-azure-recovery-services-vault-overview>`__ to "default-backups"
         #. Click the *Create new* link for *Backup policy*
         #. Set *Policy name* to "default-backups-daily"
         #. Set *Frequency* to "Daily"
         #. Set *Instant restore* to 1

      #. Click the *Next : Monitoring >* button
      #. Click the *Next : Advanced >* button
      #. Click the *Next : Tags >* button

         #. Set *Name* to the first part of the server's FQDN (e.g. ``ocp42``)

      #. Click the *Next : Review + create >* button
      #. Click the *Create* button and wait a few minutes for the server to power on

.. _create-dns-records:

3. Create DNS records
---------------------

Hostnames follow the format ``ocp##.open-contracting.org`` (ocp01, ocp02, etc.). Determine the greatest number by referring to GoDaddy and the `salt-config/roster <https://github.com/open-contracting/deploy/blob/main/salt-config/roster>`__ file. Then, increment the number by 1 for the new server, to ensure the hostname is unique and used only once.

Add A, AAAA and SPF records
~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Login to `GoDaddy <https://sso.godaddy.com>`__
#. If access was delegated, open `Delegate Access <https://account.godaddy.com/access>`__ and click the *Access Now* button
#. Open `DNS Management <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__ for open-contracting.org
#. Add an A record for the hostname:

   #. Click the *Add New Record* button
   #. Select "A" from the *Type* dropdown
   #. Enter the hostname in *Name* (``ocp42``, for example)
   #. Enter the IPv4 address in *Value*
   #. Set *TTL* to 1 **Day**

#. Add an SPF record for the hostname, because cron jobs send mail from this hostname:

   #. Click the *Add More Records* button
   #. Select "TXT" from the *Type* dropdown
   #. Enter the hostname in *Name* (``ocp42``, for example)
   #. Enter the SPF record in *Value* (``v=spf1 a:ocp42.open-contracting.org -all``, for example)
   #. Set *TTL* to 1 Hour

#. If the server has an IPv6 /64 block, add an AAAA record for the hostname:

   #. Click the *Add More Records* button
   #. Select "AAAA" from the *Type* dropdown
   #. Enter the hostname in *Name* (``ocp42``, for example)
   #. Enter the IPv6 address in *Value* (use ``2`` as the last group of digits)
   #. Set *TTL* to 1 **Day**

#. Click the *Save* button

.. seealso::

    :doc:`dns` TTL standardization

Configure reverse DNS
~~~~~~~~~~~~~~~~~~~~~

.. tab-set::

   .. tab-item:: Linode
      :sync: linode

      #. `Log into Linode <https://login.linode.com/login>`__
      #. Select the new server
      #. On the *Network* tab:

         #. Click *Edit RDNS* for the *IPv4 – Public* address
         #. Set *Enter a domain name* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
         #. Click the *Save* button
         #. If the server has an IPv6 /64 block:

            #. Click *Edit RDNS* for the *IPv6 – Range* IP block
            #. Set *Enter a domain name* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
            #. Click the *Save* button

   .. tab-item:: Hetzner Cloud
      :sync: hetzner-cloud

      #. `Log into Hetzner Cloud Console <https://console.hetzner.cloud/projects>`__
      #. Click the *Default* project
      #. On the *Primary IPs* tab:

         #. Click the *...* button for the server's IPv4 address
         #. Click the *Edit Reverse DNS* menu item
         #. Set *Reverse DNS* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
         #. Click the *Edit Reverse DNS* button
         #. If the server has an IPv6 /64 block:

            #. Click the *...* button for the server's IPv6 address
            #. Click the *Edit Reverse DNS* menu item
            #. Set the end of the IPv6 address to "::"
            #. Set *Reverse DNS* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
            #. Click the *Edit Reverse DNS* button

   .. tab-item:: Hetzner Dedicated
      :sync: hetzner-dedicated

      #. `Log into Hetzner Robot <https://robot.hetzner.com/server>`__
      #. Select the new server
      #. On the *IPs* tab (default tab):

         #. Under *IP addresses:* heading, set *Reverse DNS entry* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
         #. If the server has an IPv6 /64 block:

            #. Under the *Subnets:* heading, click the *⊕* symbol on the left
            #. Click the *Add new Reverse DNS entry* link
            #. Set *Enter IP* to the IPv6 address with ``2`` as the last group of digits
            #. Set *Enter RDNS* to the server's FQDN (e.g. ``ocp42.open-contracting.org``)
            #. Click the *Create* button

   .. tab-item:: Azure
      :sync: azure

      #. `Log into Azure <https://portal.azure.com>`__
      #. Select the new server
      #. Click on the public IP address:

         #. Enter the hostname in *DNS name label (optional)* (``ocp42``, for example)
         #. Click the *Save* button (at the top)

      #. Create an A record in GoDaddy for the configuration (e.g. ``ocp42..uksouth.cloudapp.azure.com``)

4. Apply core changes
---------------------

#. Connect to the server's FQDN as the ``root`` user (``ocpadmin`` user, if Azure) using SSH, to add it to your known hosts. Then, disconnect.

   .. warning::

      On macOS, run the ``ssh`` command with ``sudo``.

   #. On Hetzner, change the root password, using the ``passwd`` command. Use a `strong password <https://www.lastpass.com/features/password-generator>`__, and save it to OCP's `LastPass <https://www.lastpass.com>`__ account.

#. Add a target to the ``salt-config/roster`` file in this repository. Name the target after the service.

   -  If the service is moving to a new server, use the old target's name for the new target, and add a ``-old`` suffix to the old target's name.
   -  If the service is an instance of `CoVE <https://github.com/OpenDataServices/cove>`__, add a ``cove-`` prefix.
   -  If the environment is development, add a ``-dev`` suffix.
   -  Do not include an integer suffix in the target name.

   .. warning::

      On Azure, add ``user: ocpadmin`` and ``sudo: true`` to the `target's data <https://docs.saltproject.io/en/latest/topics/ssh/roster.html#targets-data>`__.

   .. tip::

      If DNS is not propagated, temporarily set ``host`` to the server's IP address instead of its hostname.

#. :doc:`../develop/update/network`, adding the target to the ``pillar/top.sls`` file, if needed.

   .. attention::

      If using Docker, add ``docker:`` to the service's Pillar file, to not configure a server-side :doc:`firewall<../develop/update/firewall>`.

#. Run the `onboarding <https://github.com/open-contracting/deploy/blob/main/salt/onboarding.sls>`__ and core state files (replace ``TARGET``).

   .. code-block:: bash

      salt-ssh --log-level=trace TARGET state.apply 'onboarding,core*'

   .. note::

      This step takes 3-4 minutes, so ``--log-level=trace`` is used to show activity.

   .. tip::

      If configuring a non-OCP server:

      #. Suffix ``-test`` to the target's name in the ``salt-config/roster`` file
      #. Comment out the ``'*'`` section in the ``pillar/top.sls`` file
      #. If configuring Apache, edit the ``salt/apache/files/404.html`` file

      The service's Pillar file needs ``system_contacts``, ``network.domain``, ``ssh.admin``, ``locale``, ``ntp`` and, preferably, ``maintenance`` sections.

#. `Reboot the server <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.system.html#salt.modules.system.reboot>`__:

   .. code-block:: bash

      ./run.py TARGET system.reboot

.. note::

   The hostname configured in this step and the DNS records created in the previous step are relevant to:

   -  verify that an email message has a legitimate source (for example, from cron jobs)
   -  communicate between servers (for example, for database replication)
   -  identify servers in human-readable way

   As such, DNS records that match the hostname must be maintained, until the server is decommissioned.

5. Deploy the service
---------------------

#. If the service is being introduced, add the target to the ``salt/top.sls`` and ``pillar/top.sls`` files, and include any new state or Pillar files you authored for the service.

#. If the service is moving to the new server, update occurrences of the old server's hostname and IP address. (In some cases described in the next step, you'll need to deploy the related services.)

#. :doc:`Deploy the service<deploy>`.

Some IDs might fail (`#156 <https://github.com/open-contracting/deploy/issues/156>`__):

-  ``uwsgi``, using the ``service.running`` function. If so, run:

   .. code-block:: bash

      ./run.py TARGET service.restart uwsgi

.. _migrate-server:

6. Migrate from the old server
------------------------------

#. :ref:`check-mail` for the root user and, if applicable, each app user
#. :ref:`Check the user directory<clean-root-user-directory>` of the root user and, if applicable, each app user
#. If the server runs a database like PostgreSQL (``pg_dump``), MySQL (``mysqldump``) or Elasticsearch, copy the database
#. If the server runs a web server like Apache or application server like uWSGI, optionally copy the log files

Data support server
~~~~~~~~~~~~~~~~~~~

See :doc:`data-support`.

Django applications
~~~~~~~~~~~~~~~~~~~

#. Copy the ``media`` directory and the ``db.sqlite3`` file from the app's directory

OCDS documentation
~~~~~~~~~~~~~~~~~~

#. Copy the ``/home/ocds-docs/web`` directory. For example:

   .. code-block:: bash

      rsync -avz ocp99:/home/ocds-docs/web/ /home/ocds-docs/web/

#. Stop Elasticsearch, replace the ``/var/lib/elasticsearch/`` directory, and start Elasticsearch. For example:

   .. code-block:: bash

      systemctl stop elasticsearch
      rm -rf /var/lib/elasticsearch/*
      rsync -avz ocp99:/var/lib/elasticsearch/ /var/lib/elasticsearch/
      systemctl start elasticsearch

#. Mark the ``elasticsearch`` package as held back:

   .. code-block:: bash

      apt-mark hold elasticsearch

Prometheus
~~~~~~~~~~

#. Stop Prometheus, replace the ``/home/prometheus-server/data/`` directory, and start Prometheus. For example:

   .. code-block:: bash

      systemctl stop prometheus-server
      rm -rf /home/prometheus-server/data/*
      rsync -avz ocp99:/home/prometheus-server/data/ /home/prometheus-server/data/
      systemctl start prometheus-server

#. Update the IP addresses in the ``pillar/prometheus_client.sls`` file, and deploy to all services

.. _update-external-services:

7. Update external services
---------------------------

#. :doc:`Add the server to Prometheus<prometheus>`
#. Add (or update) the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__, for example:

   #. Click the *Add New Record* button
   #. Select "CNAME" from the *Type* dropdown
   #. Enter the public hostname in *Name* (``standard``, for example)
   #. Enter the internal hostname in *Value* (``ocp42.open-contracting.org``, for example)
   #. Leave *TTL* at the 1 Hour default
   #. Click the *Save* button

   .. seealso::

       :doc:`dns`

#. Add (or update) the service's row in the `Health of software products and services <https://docs.google.com/spreadsheets/d/1MMqid2qDto_9-MLD_qDppsqkQy_6OP-Uo-9dCgoxjSg/edit#gid=1480832278>`__ spreadsheet
#. Add (or update) managed passwords, if appropriate
#. Contact Dogsbody Technology to set up maintenance (`see readme <https://github.com/open-contracting/dogsbody-maintenance#readme>`__)
#. :doc:`Delete the old server<delete_server>`

If the service is being introduced:

#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__
#. Add the embed code for `Fathom Analytics <https://app.usefathom.com/>`__, if appropriate

If the service uses a new top-level domain name:

#. Add the domain to `Google Search Console <https://search.google.com/search-console>`__
