Running these on OCP Servers
============================

To run these on OCP Servers,

* you need access to the main public repository.
* you need access to the two private repositories.
* your SSH Key needs to already be set up on the servers.


To check out all repositories in the correct place on your computer:

.. code-block:: bash

    git clone git@github.com:open-contracting/deploy.git open-contracting-deploy
    cd open-contracting-deploy
    git clone git@github.com:open-contracting/deploy-salt-private.git salt/private
    git clone git@github.com:open-contracting/deploy-pillar-private.git pillar/private


