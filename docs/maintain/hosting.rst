Hosting tasks
=============

.. _rescale-server:

Rescale a server
----------------

Linode makes it easy to `scale/resize <https://www.linode.com/docs/products/compute/compute-instances/guides/resize/>`__ a server (number of cores and GiB of RAM).

You must :doc:`deploy the service<../deploy/deploy>` to re-configure swap, Elasticsearch, PostgreSQL and/or uWSGI.

Manager cloud services
----------------------

Azure
~~~~~

Configure Azure portal
^^^^^^^^^^^^^^^^^^^^^^

#. Open the `Directories + subscriptions <https://portal.azure.com/#settings/directory>`__ settings
#. Set *Default subscription filter* to "All subscriptions"

Configure Azure CLI
^^^^^^^^^^^^^^^^^^^

#. Install the `Azure CLI <https://learn.microsoft.com/en-us/cli/azure/>`__
#. Log in to Azure:

   .. code-block:: bash

      az login

#. Set the default subscription:

   .. code-block:: bash

      az account set --subscription 4e98b5b1-1619-44be-a38e-90cdb8e4bc95

#. Set the default resource group:

   .. code-block:: bash

      az configure --defaults group=default

.. seealso::

   `Commands <https://learn.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest>`__

.. _recover-server:

Recover a server
----------------

If a server becomes inaccessible, including via SSH, log into the hosting provider and:

1. Reboot the server. This often restores access, as unsaved changes to firewall rules are reset, system resources are freed, and running processes are restarted.
2. Use a recovery system to restore access if the server remains inaccessible.

.. tab-set::

   .. tab-item:: Linode

      `Lish (Linode Shell) <https://www.linode.com/docs/products/compute/compute-instances/guides/lish/>`__ provides console access to our Linode instances, similar to connecting via SSH.

      #. `Log into Linode <https://login.linode.com/login>`__
      #. Select the server you want to access
      #. Click the *Launch LISH Console* link
      #. Login as ``root``, using the password from OCP's `LastPass <https://www.lastpass.com>`__ account

   .. tab-item:: Hetzner Cloud

      Hetzner Cloud offers two recovery methods.

      .. tab-set::

         .. tab-item:: Console

            #. `Log into Hetzner Cloud Console <https://console.hetzner.cloud/projects>`__
            #. Click the *Default* project
            #. Select the server you want to access
            #. Click the *Actions* button
            #. Click the *Console* menu item

         .. tab-item:: Hetzner Rescue System

            #. `Log into Hetzner Cloud Console <https://console.hetzner.cloud/projects>`__
            #. Click the *Default* project
            #. Select the server you want to access
            #. Activate the rescue system:

               #. Click the *Rescue* tab
               #. Click the *Enable rescue & power cycle* button
               #. Set *Choose a Rescue OS* to *linux64*
               #. Select your key for *SSH key* (if missing, add it via the project's *Security* menu item)
               #. Click the *Enable rescue* button

            #. Connect to the server as the ``root`` user using SSH

   .. tab-item:: Hetzner Dedicated

      Hetzner Dedicated offers two recovery methods.

      .. tab-set::

         .. tab-item:: Hetzner Rescue System

            The `Hetzner Rescue System <https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/>`__ boots the server using a temporary recovery image, from which we can mount the server drives to fix issues.

            #. `Log into Hetzner Robot <https://robot.hetzner.com/server>`__
            #. Select the server you want to access
            #. Activate the rescue system:

               #. Click the *Rescue* tab
               #. Set *Operating system* to *Linux*
               #. Set *Architecture* to *64 bit*
               #. Select your key for *Public key* (if missing, add it in `Key management <https://robot.hetzner.com/key/index>`__)
               #. Click the *Activate rescue system* button

            #. Reboot the server:

               #. Click the *Reset* tab
               #. Set *Reset type* to *Press power button of server* or *Send CTRL+ALT+DEL to the server*
               #. Click the *Send* button

               It takes some time to process the instruction. If nothing happens after 5 minutes, try again using *Execute an automatic hardware reset*.

            #. Connect to the server as the ``root`` user using SSH

            #. Mount the drive(s):

               .. code-block:: bash

                  mount /dev/md/2 /mnt

            #. Optionally, ``chroot`` into the operating system:

               .. code-block:: bash

                  chroot-prepare /mnt
                  chroot /mnt

         .. tab-item:: KVM Console

            Hetzner technicians attach a remote console (`KVM Console <https://docs.hetzner.com/robot/dedicated-server/maintainance/kvm-console/>`__) to a dedicated server. This option is slow to set up, but might be required if the issue is with the network, firewall or SSH configuration.

   .. tab-item:: Azure

      #. `Log into Azure <https://portal.azure.com>`__
      #. Click the *Virtual machines* icon
      #. Select the server you want to access
      #. Click the *Connect* menu item
      #. Expand the *More ways to connect* detail
      #. Click the *Go to serial console* button
      #. Login as ``ocpadmin``, using the password from OCP's `LastPass <https://www.lastpass.com>`__ account

      .. seealso::

         `Azure Serial Console <https://learn.microsoft.com/en-us/troubleshoot/azure/virtual-machines/windows/serial-console-overview>`__
