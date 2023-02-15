Get started
===========

.. note::

   Only follow the Development Guides if you will be configuring or deploying servers. If you are simply using services, read the :doc:`../use/index`.

1. Install requirements
-----------------------

.. code-block:: bash

    pip install --no-deps -r requirements.txt

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

Add your public SSH key to the ``ssh.root`` list in the target's Pillar file, or to the ``ssh.admin`` list in the ``pillar/common.sls`` file if you require root access to all servers. For example:

.. code-block:: bash

    vi pillar/kingfisher.sls
    git commit pillar/kingfisher.sls -m "ssh: Add public key for Jane Doe"
    git push origin main

Then, ask a colleague to deploy your public SSH key to the relevant servers. For example:

.. code-block:: bash

    ./run.py '*' state.sls_id root_authorized_keys core.sshd

4. Configure Salt for non-root user
-----------------------------------

Unless your local user is the root user, run:

.. code-block:: bash

    ./script/setup

This script assumes your SSH keys are ``~/.ssh/id_rsa`` and ``~/.ssh/id_rsa.pub``.

You're now ready to :doc:`../deploy/deploy`.
