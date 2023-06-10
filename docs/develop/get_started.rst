Get started
===========

.. note::

   Only follow the Development Guides if you will be configuring or deploying servers. If you are simply using services, read the :doc:`../use/index`.

1. Install dependencies
-----------------------

Follow the `Salt install guide <https://docs.saltproject.io/salt/install-guide/en/latest/>`__ to install Salt on your platform.

.. note::

   On at least macOS, you should stop the Salt minion service:

   .. code-block:: bash

      launchctl stop com.saltstack.salt.minion

   and disable the *Salt Stack, Inc.* login item (System Settings... > General > Login Items).

`Click <https://click.palletsprojects.com/>`__ must be available to Salt's environment:

.. code-block:: bash

   sudo salt-pip install click

2. Clone repositories
---------------------

You must first have access to three private repositories. Contact an owner of the open-contracting organization on GitHub for access. Then:

.. code-block:: bash

   git clone git@github.com:open-contracting/deploy.git
   git clone git@github.com:open-contracting/deploy-pillar-private.git deploy/pillar/private
   git clone git@github.com:open-contracting/deploy-salt-private.git deploy/salt/private
   git clone git@github.com:open-contracting/dogsbody-maintenance.git deploy/salt/maintenance

.. _add-public-key:

3. Add your public SSH key to remote servers
--------------------------------------------

.. tip::

   To generate an SSH key pair (if they do not already exist):

   .. code-block:: bash

      ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

   This creates both public (``~/.ssh/id_rsa.pub``) and private (``~/.ssh/id_rsa``) keys.

Add your public SSH key to the ``ssh.root`` list in the target's Pillar file, or to the ``ssh.admin`` list in the ``pillar/common.sls`` file if you require root access to all servers. For example:

.. code-block:: bash

   vi pillar/common.sls
   git commit pillar/common.sls -m "ssh: Add public key for Jane Doe"
   git push origin main

Then, ask James or Yohanna to deploy your public SSH key to the relevant servers. For example:

.. code-block:: bash

   ./run.py '*' state.sls_id root_authorized_keys core.sshd

4. Configure Salt for non-root user
-----------------------------------

Run:

.. code-block:: bash

   ./script/setup

This overwrites the files:

-  ``salt-config/master.d/localuser.conf``
-  ``salt-config/master``
-  ``salt-config/pki/ssh/salt-ssh.rsa.pub``
-  ``salt-config/pki/ssh/salt-ssh.rsa``
-  ``Saltfile``

.. note::

   On macOS, you might need to move ``Saltfile`` to ``~/.salt/Saltfile``.

This script assumes your SSH key pair is ``~/.ssh/id_rsa.pub`` and ``~/.ssh/id_rsa``.

You're now ready to :doc:`../deploy/deploy`.
