Hosting
=======

Rescale a server
----------------

The Bytemark and Linode Control Panels make it easy to scale/resize a server (number of cores and GiB of RAM).

You must :doc:`deploy the service<../deploy/deploy>` to re-configure swap, Elasticsearch, PostgreSQL and/or uWSGI.

Recover a server
----------------

If a server becomes inaccessible, including via SSH, log into the hosting provider and:

1. Reboot the server. This often restores access, as unsaved changes to firewall rules are reset, system resources are freed, and running processes are restarted.
2. Use a recovery system to restore access if the server remains inaccessible.

Linode
~~~~~~

`Lish (Linode Shell) <https://www.linode.com/docs/guides/using-the-lish-console/>`__ provides console access to our Linode instances, similar to connecting via SSH.

#. `Log into Linode <https://login.linode.com/>`__
#. Select the server you want to access
#. Click *Launch LISH Console*
#. Login as ``root``, using the password from OCP's `LastPass <https://www.lastpass.com>`__ account

Hetzner
~~~~~~~

Hetzner offers two recovery methods.

Hetzner Rescue System
^^^^^^^^^^^^^^^^^^^^^

The `Hetzner Rescue System <https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/>`__ boots the server using a temporary recovery image, from which we can mount the server drives to fix issues.

#. `Log into Hetzner <https://robot.your-server.de/server>`__
#. Select the server you want to access
#. Activate the rescue system:

   #. Click the *Rescue* tab
   #. Set *Operating system* to *Linux*
   #. Set *Architecture* to *64 bit*
   #. Select your key for *Public key* (if missing, add it in `Key management <https://robot.your-server.de/key/index>`__)
   #. Click *Activate rescue system*

#. Reboot the server:

   #. Click the *Reset* tab
   #. Set *Reset type* to *Press power button of server* or *Send CTRL+ALT+DEL to the server*
   #. Click *Send*

   It takes some time to process the instruction. If nothing happens after 5 minutes, try again using *Execute an automatic hardware reset*.

#. Connect to the server as the ``root`` user using SSH

#. Mount the drive(s):

   .. code-block:: bash

      mount /dev/md/2 /mnt

#. Optionally, ``chroot`` into the operating system:

   .. code-block:: bash

      chroot-prepare /mnt
      chroot /mnt

KVM Console
^^^^^^^^^^^

Hetzner technicians attach a remote console (`KVM Console <https://docs.hetzner.com/robot/dedicated-server/maintainance/kvm-console/>`__) to a dedicated server. This option is slow to set up, but might be required if the issue is with the network, firewall or SSH configuration.
