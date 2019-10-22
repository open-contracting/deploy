Deploy
======

We use `Salt <https://docs.saltstack.com/en/latest/>`__ (a.k.a. SaltStack) to deploy apps to servers, and to otherwise manage servers.

All changes to servers should be made as documented here to ensure that changes are documented and reproducible; changes should not be made manually, which is undocumented and error-prone.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

.. toctree::
   :maxdepth: 3

   how-to/index.rst
   reference/index.rst
