Deploy
======

All changes to servers should be made as documented here to ensure that changes are documented and reproducible; changes should not be made manually, which is undocumented and error-prone.

Salt
----

We use `Salt <https://docs.saltstack.com/en/latest/>`__ (a.k.a. SaltStack) to deploy apps to servers, and to otherwise manage servers.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

To orient you to the repository: When you run the ``salt-ssh`` command, it reads ``Saltfile``, which directs it to read the ``salt-config`` directory. ``salt-config/master`` directs it to read the ``salt`` and ``pillar`` directories. The ``top.sls`` file in each directory serves as an index to the other SLS files, which in turn refer to the files in sub-directories.

Read `Salt Best Practices <https://docs.saltstack.com/en/latest/topics/best_practices.html>`__ and `Salt Formulas Style <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#style>`__ before editing this repository.

.. toctree::
   :maxdepth: 2

   how-to/index.rst

.. toctree::
   :maxdepth: 3

   reference/index.rst

.. toctree::
   :caption: Service-specific tasks
   :maxdepth: 2

   how-to/kingfisher.rst
   how-to/docs.rst
