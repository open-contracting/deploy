Get started
===========

1. Install Salt
---------------

On macOS, using Homebrew, install Salt and Salt SSH with:

.. code-block:: bash

    brew install salt

For other operating systems and package managers, see `this page <https://repo.saltstack.com/>`__ (or `this page <https://docs.saltstack.com/en/latest/topics/installation/index.html>`__) to install a recent version (2019 or later).

To install Salt on a virtual machine on macOS, you can:

#. `Download and install VirtualBox <https://www.virtualbox.org/wiki/Downloads>`__
#. `Download the latest image of the CLI Version of Arch Linux <https://www.osboxes.org/arch-linux/>`__
#. Create a virtual machine:

   #. Open VirtualBox
   #. Click "New"
   #. Set "Name" to "Salt", "Type" to "Linux", "Version" to "Linux 2.6 / 3.x / 4.x (64-bit)", and click "Continue" twice
   #. Select "Use existing hard disk", select the image, and click "Create"

#. Click "Settings", "Shared Folders", and the new folder icon
#. Set "Folder Path:" to the path of the local copy of this repository, check "Make Permanent" (if present), and click "OK"
#. Start the virtual machine, login with `osboxes / osboxes.org <https://www.osboxes.org/arch-linux/#archlinux-201905-info>`__, and run:

.. code-block:: bash

   sudo pacman -Syu
   sudo systemctl enable vboxservice
   sudo usermod -a -G vboxsf `whoami`
   sudo pacman -S openssh python2-pip salt
   sudo pip2 install salt-ssh
   sudo mount -t vboxsf -o uid=1000,gid=1000 deploy /mnt
   cd /mnt

However, even after reconfiguring ``localuser.conf``, ``sudo salt-ssh -c salt-config '*' test.ping -v`` hangs without output and ``-l debug`` offers no insights.

Reference: `Arch Linux VirtualBox <https://wiki.archlinux.org/index.php/VirtualBox>`__, `Investigating boot errors <https://wiki.archlinux.org/index.php/systemd#Investigating_systemd_errors>`__.

2. Clone repositories
---------------------

You must first have access to two private repositories. Contact an owner of the open-contracting organization on GitHub for access. Then:

.. code-block:: bash

    git clone git@github.com:open-contracting/deploy.git
    git clone git@github.com:open-contracting/deploy-salt-private.git deploy/salt/private
    git clone git@github.com:open-contracting/deploy-pillar-private.git deploy/pillar/private

Note: This documentation is for working with OCP servers. If you want to work with other servers, then instead of cloning the private repositories, copy and edit the template directories:

.. code-block:: bash

    git clone git@github.com:open-contracting/deploy.git
    cp -r deploy/pillar/private-templates deploy/pillar/private
    cp -r deploy/salt/private-templates deploy/salt/private

3. Add public key to remote servers
-----------------------------------

Add your public key to ``salt/private/authorized_keys/root_to_add``, e.g.:

.. code-block:: bash

    cat ~/.ssh/id_rsa.pub >> salt/private/authorized_keys/root_to_add
    git commit salt/private/authorized_keys/root_to_add -m "Add public key"
    git push origin master

Then, add this public key to all servers:

.. code-block:: bash

    salt-ssh -i '*' root_authorized_keys_add

4. Configure Salt for non-root user
-----------------------------------

Unless your local user is the root user, run:

.. code-block:: bash

    ./script/setup

This script assumes your SSH keys are ``~/.ssh/id_rsa`` and ``~/.ssh/id_rsa.pub``.

You're now ready to :doc:`deploy`.
