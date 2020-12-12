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

To test whether a mapping key is present, use the ``in`` operator:

.. code-block:: jinja

   {% if 'child' in pillar.parent %}

To test whether an optional boolean is true, use the ``.get()`` method:

.. code-block:: jinja

   {% if pillar.parent.get('enabled') %}

If a Pillar key might not be set, use ``.get()``:

.. code-block:: jinja

   {{ pillar.parent.get('child') }}

If many parts of a Pillar key might not be set, use ``salt['pillar.get']()``:

.. code-block:: jinja

   {{ salt['pillar.get']('parent:child') }}

Note the colon (``:``) between ``parent`` and ``child``.

YAML style
----------

Pillar keys
  To allow the use of dot notation in Jinja templates, prefer underscores to hyphens in Pillar keys.
State IDs
  While state IDs with spaces are easier to read, they are also easier to mistype: for example, in ``watch_in`` arguments. As such, prefer hyphens to spaces in state IDs.
Booleans
  Capitalize ``True`` and ``False``, for consistency.

State functions
---------------

cmd
~~~

In general, avoid the `cmd.run <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.cmd.html>`__ function. For most system commands, Salt provides a `state function <https://docs.saltstack.com/en/latest/ref/states/all/index.html>`__.

Our use is limited to:

-  Activating and running a Python command within a virtual environment
-  Running a custom script that is specific to our services
-  Running a system command for which Salt has no relevant function (rare)

Excluding virtual environments, ``cmd.run`` is used less than 10 times in the repository.

When using ``cmd.run``, you should set an ``onchanges`` requisite or a ``creates`` argument. Otherwise, a ``cmd.run`` function is run each time its state file is applied.

file
~~~~

If possible, avoid `file <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.file.html>`__ functions. For many system files, Salt provides a `state function <https://docs.saltstack.com/en/latest/ref/states/all/index.html>`__.

Our use is limited to:

-  Writing a custom file or creating a custom directory that is specific to our services
-  Updating a system file for which Salt has no relevant function (uncommon)

Note that unarchiving files (whether local or remote) should use the `archive.extracted function <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.archive.html>`__.

.. _service-functions:

service
~~~~~~~

The Salt documentation `states <https://docs.saltstack.com/en/latest/ref/states/all/salt.states.service.html>`__:

   By default if a service is triggered to refresh due to a watch statement the service is restarted. If the desired behavior is to reload the service, then set the reload value to True.

Some configuration changes require a reload only, while others require a restart. To support both, we author IDs like:

.. code-block:: yaml

   apache2:
     service.running:
       - name: apache2
       - enable: True

   apache2-reload:
     module.wait:
       - name: service.reload
       - m_name: apache2

   proxy:
     apache_module.enabled:
       - name: proxy
       - watch_in:
         - service: apache2

   enable-letsencrypt-conf:
     apache_conf.enabled:
       - name: letsencrypt
       - watch_in:
         - module: apache2-reload

In this example, enabling the ``proxy`` module causes the ``apache2`` service to restart, whereas enabling the ``letsencrypt`` configuration causes it to reload.

Includes
--------

As the Salt documentation `states <https://docs.saltstack.com/en/getstarted/config/include.html>`__, with respect to whether to use an include or the top file:

   If a Salt state always needs some other state, then using an include is a better choice. If only some systems should receive both Salt states, including both states in the top file gives you the flexibility to choose which systems receive each.

In other words: If running ``state.apply my-state`` fails with an error like:

.. code-block:: none

   - Cannot extend ID 'my-id' in 'base:my-state'. It is not part of the high state.
     This is likely due to a missing include statement or an incorrectly typed ID.
     Ensure that a state with an ID of 'my-id' is available
     in environment 'base' and to SLS 'my-state'

then the state file that defines the ``my-id`` ID should be included in the ``my-state`` file. Otherwise, it shouldn't.

Requisites
----------

Instead of relying on `ordering <https://docs.saltstack.com/en/getstarted/config/requisites.html>`__, it's better to explicitly declare direct `requisites <https://docs.saltstack.com/en/latest/ref/states/requisites.html>`__. We use exclusively:

-  `require <https://docs.saltstack.com/en/latest/ref/states/requisites.html#require>`__ is easier to reason about than ``require_in``, because code typically declares its own dependencies.
-  `watch_in <https://docs.saltstack.com/en/latest/ref/states/requisites.html#watch>`__  is easier to reason about than ``watch``, because it follows the direction of causation: if *this* state changes, then :ref:`restart or reload<service-functions>` *that* service.
-  `onchanges <https://docs.saltstack.com/en/latest/ref/states/requisites.html#onchanges>`__ makes a state only apply if the require state generates changes, and is used exclusively with the ``cmd.run`` function (which otherwise always applies).
-  `listen <https://docs.saltstack.com/en/latest/ref/states/requisites.html#requisites-listen>` is used once, where multiple IDs modify a file that is required by a service.

Macros
------

As the Salt documentation `states <https://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html#jinja-macros>`__:

   Jinja macros are useful for one thing and one thing only: creating mini templates that can be reused and rendered on demand.

All macros are defined in `lib.sls <https://github.com/open-contracting/deploy/blob/master/salt/lib.sls>`__.

-  :doc:`set_firewall() and unset_firewall()<update/firewall>` make sense as macros, because different state files might want to open or close different ports based on Pillar data. For example, the ``apache`` file opens or closes ports 80 and 443 based on the ``apache.public_access`` value.
-  ``apache()`` makes sense as a macro, because it is called from two different contexts: when processing ``apache.sites`` data in the ``apache`` file, and ``python_apps`` data in the ``python`` file. See `#80 <https://github.com/open-contracting/deploy/issues/80#issuecomment-739122716>`__.

Looping over Pillar data
------------------------

A few state files loop over Pillar data:

-  :doc:`core.rsyslog and core.logrotate<update/logs>`
-  :doc:`apache<update/apache>`, included by the top file if the ``apache.sites`` key is set in Pillar data
-  :doc:`python_apps<update/python>`, included by the state files of specific services
-  ``prometheus``, included by the state file of the ``prometheus`` service, and by non-development targets in the top file

This pattern allows configuration to live in Pillar, rather than in Salt.

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
