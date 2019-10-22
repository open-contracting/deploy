Deploy
======

Salt
----

We use `Salt <https://docs.saltstack.com/en/latest/>`__ (a.k.a. SaltStack) to deploy apps to servers, and to otherwise manage servers.

All changes to servers should be made as documented here to ensure that changes are documented and reproducible; changes should not be made manually, which is undocumented and error-prone.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

.. toctree::
   :maxdepth: 2

   how-to/index.rst
   reference/index.rst

Travis deploy scripts
---------------------

The repositories for OCDS documentation websites use Travis' `script deployment <https://docs.travis-ci.com/user/deployment/script/>`__ to run the `deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ script in this repository.

This script requires the ``PRIVATE_KEY`` and ``SEARCH_SECRET`` to be `set on Travis <https://ocds-standard-development-handbook.readthedocs.io/en/latest/standard/technical/integrations.html#travis-ci>`__:

-  ``SEARCH_SECRET`` is the value of the ``ocds_secret`` key in ``pillar/private/standard_search_pillar.sls``
-  ``PRIVATE_KEY`` is the content of ``salt/private/ocds-docs/ssh_authorized_keys_from_travis_private``

Changes to this script are made via pull request.
