Running these on your Servers
=============================


To run these on your own Servers, you need to create and store 2 repositories of private data. These repositories should not be public.

We provide templates of what should be in each private repository, so it is easy to get started.

.. code-block:: bash

    git clone git@github.com:open-contracting/deploy.git open-contracting-deploy
    cd open-contracting-deploy
    cp -r pillar/private-templates pillar/private
    cp -r salt/private-templates salt/private

You then need to manage the contents of these two private folders, `pillar/private` and `salt/private`. We recommend making a git repository for each one,
and then making sure the git repository is hosted privately. But it is up to you how you do this.



