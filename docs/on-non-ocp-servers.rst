On non-OCP Servers
==================

It's possible to deploy the code for any OCP hosted service (such as Kingfisher, Toucan or the Data Review Tool) on your
own infrastructure. For example, you may want to integrate them into your own web services.

To run these on your own non-OCP servers, you need to create and store 2 repositories of private data. These repositories should not be public.

We provide templates of what should be in each private repository, so it is easy to get started.

.. code-block:: bash

    git clone git@github.com:open-contracting/deploy.git open-contracting-deploy
    cd open-contracting-deploy
    cp -r pillar/private-templates pillar/private
    cp -r salt/private-templates salt/private

You then need to manage the contents of these two private folders, `pillar/private` and `salt/private`. We recommend making a git repository for each one,
and then making sure the git repository is hosted privately.



