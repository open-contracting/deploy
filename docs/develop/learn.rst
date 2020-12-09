Learn Salt
==========

We use `Salt <https://docs.saltstack.com/en/latest/>`__ (a.k.a. SaltStack) to deploy apps to servers, and to otherwise manage servers.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

To orient you to the repository: When you run the ``./run.py`` script, it calls the ``salt-ssh`` command, which reads ``Saltfile``, which directs it to read the ``salt-config`` directory. ``salt-config/master`` directs it to read the ``salt`` and ``pillar`` directories. The ``top.sls`` file in each directory serves as an index to the other SLS files, which in turn refer to the files in sub-directories.

Read `Salt Best Practices <https://docs.saltstack.com/en/latest/topics/best_practices.html>`__ and `Salt Formulas Style <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#style>`__ before editing this repository.

Jinja style
-----------

Use dot notation:

.. code-block:: jinja

   {{ pillar.host_id }}
   {{ grains.kernel }}

**AVOID** bracket notation:

.. code-block:: jinja

   {{ pillar['host_id'] }}  # AVOID
   {{ grains['kernel'] }}  # AVOID

If a Pillar key might not be set, use ``.get()``:

.. code-block:: jinja

   {{ pillar.parent.get('child') }}

If many parts of a Pillar key might not be set, use ``salt['pillar.get']()``:

.. code-block:: jinja

   {{ salt['pillar.get']('parent:child') }}

Note the colon (``:``) between ``parent`` and ``child``.

cmd functions
-------------

In general, avoid the `cmd.run <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html>`__ function. For most system commands, Salt provides a `state function <https://docs.saltstack.com/en/latest/ref/states/all/index.html>`__.

Our use is limited to:

-  Activating and running a Python command within a virtual environment
-  Running a custom script that is specific to our services
-  Running a system command for which Salt has no relevant function (rare)

Excluding virtual environments, ``cmd.run`` is used less than 10 times in the repository.

When using ``cmd.run``, you should set an ``onchanges`` requisite or a ``creates`` argument. Otherwise, a ``cmd.run`` function is run each time its state file is applied.

file functions
--------------

If possible, avoid `file <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.file.html>`__ functions. For many system files, Salt provides a `state function <https://docs.saltstack.com/en/latest/ref/states/all/index.html>`__.

Our use is limited to:

-  Writing a custom file or creating a custom directory that is specific to our services
-  Updating a system file for which Salt has no relevant function (uncommon)

Note that unarchiving files (whether local or remote) should use the `archive.extracted function <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.archive.html>`__.

grains
------

To make states more reusable, use `Grains <https://docs.saltstack.com/en/latest/topics/grains/>`__ where possible. Common grains with example values are:

cpuarch
  ``x86_64``
kernel
  ``Linux`` (capitalized)
os
  ``Ubuntu`` (capitalized)
osarch
  ``amd64``
oscodename
  ``bionic``
fqdn
  The server's fully-qualified domain name.
fqdn_ip4
  The server's IPv4 address.
fqdn_ip6
  The server's IPv6 address.
mem_total
  The amount of RAM, in megabytes.
num_cpus
  The number of CPUs.
