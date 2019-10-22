Deploy
======

Salt
----

We use `Salt (a.k.a. SaltStack) <https://docs.saltstack.com/en/latest/>`__ to deploy applications to servers, and to otherwise manage servers.

All changes to servers should be made as documented here to ensure that changes are documented and reproducible; changes should not be made manually, which is undocumented and error-prone.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

.. toctree::
   :maxdepth: 1

   get_started.rst
   deploy.rst
   monitor.rst
   update.rst

Travis deploy scripts
---------------------

We use `Travis CI <https://travis-ci.org>`__ for continuous integration. The repositories for OCDS documentation websites use Travis' `script deployment <https://docs.travis-ci.com/user/deployment/script/>`__ to run the `deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ script in this repository. Changes to this script are made via pull request.
