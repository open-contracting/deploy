Hosting
=======

Rescale a server
----------------

The Bytemark and Linode Control Panels makes it easy to scale/resize a server (number of cores and GiB of RAM).

You must :doc:`deploy the service<../deploy/deploy>` to re-configure swap, Elasticsearch, PostgreSQL and/or uWSGI.

Recovery
--------

In the event that a server is inaccessible including via SSH there are a number of recovery systems we can use to restore access.

The first step regardless of the ISP is to initiate a reboot via the server provider.
This will clear down the current server state (unsaved firewall rules, running processes and system resources (CPU / Memory)), often this will bring the server back online.

Linode
^^^^^^
LISH (Linode Shell) is a console hosted by Linode providing direct access to our servers.
Using the LISH console we can login directly as if we were connecting to the instance locally.

To access LISH:
#. Log into Linode
#. Select the server you want to access
#. Select *Launch LISH Console*
#. Connect as the ``root`` user using the password stored in `LastPass <https://www.lastpass.com>`__.

`Linode documentation including SSH tunnelling with LISH <https://www.linode.com/docs/guides/using-the-lish-console/>`__.

Hetzner
^^^^^^^
The Hetzner rescue system works by booting the server onto a temporary recovery image, from here we can mount the server disks and fix issues directly.

To set up the rescue system:
#. `Log into Hetzner <https://robot.your-server.de/server>`__
#. Select the server you want to access
#. Enable the Rescue System, select *Rescue*
   #. Operating system: Linux
   #. Architecture: 64 bit
   #. Public key: Select your key
   #. *Activate rescue system*

   The rescue system will now be used next time we reboot.

.. Note::

   If your key is not in Hetzner you can upload it under the `*Key management* page<https://robot.your-server.de/key/index>`__.

#. Reboot the server
   #. Select the *Reset* heading
   #. *Send CTRL+ALT+DEL to the server*
   #. *Send*

   It will take a few minutes for the reboot to process, if nothing has happened after 5 minutes, try again using *Execute an automatic hardware reset*.

#. ssh onto the server using the key specified above

#. *mount* the disk

   .. code-block:: bash

      mount /dev/md/2 /mnt

#. Optionally, *chroot* into the operating system

   .. code-block:: bash

      chroot-prepare /mnt
      chroot /mnt

`Hetzner documentation <https://docs.hetzner.com/robot/dedicated-server/troubleshooting/hetzner-rescue-system/>`__.

KVM Access
""""""""""
An alternative Hetzner recovery method is to request a KVM Console.
With this a Hetzner plug a separate KVM system into the server providing access to the server as if we were connecting locally.
This mitigates any issues with Network, Firewall or SSHD configuration.

KVM sessions can be slow to set up as we need to wait for a Hetzner Support technician to physically access our server.

Information on ordering and using KVM can be found in the `Hetzner documentation<https://docs.hetzner.com/robot/dedicated-server/maintainance/kvm-console/>`__.
