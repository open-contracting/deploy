Deploying
=========

Make sure you are the only one deploying
----------------------------------------

There should be a way to make sure that only one person is trying to change a server at a time.

Currently we use a wiki page that only Open Data Services Coop have access to. This means only Open Data Services Coop should deploy to live servers.

TODO - Work out how we're going to make a deploy token work between Open Data Services and OCP, so that OCP staff can deploy. Document.

Make sure you have the latest scripts
-------------------------------------

You can run

.. code-block:: bash

    git checkout master
    git pull --rebase
    git submodule update --remote --merge

This will update all 3 repositories (public and 2 private ones) to the master branch and the latest version,
whilst showing you the git messages so you can see if there are any conflicts or problems switching.

Deploy with the salt-ssh command
--------------------------------

To deploy the latest app and supporting software to a server, use the salt-ssh command.

.. code-block:: bash

    salt-ssh -i 'ocds-docs-staging' state.highstate

You only need '-i' the first time that you run this command.
