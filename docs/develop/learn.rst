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

Writing a configuration file
----------------------------

To make a configuration file more reusable:

-  Use values from Pillar data, instead of hardcoding values.
-  Set sensible defaults, for example:

   .. code-block:: jinja

      {{ entry.uwsgi.get('max-requests', 1024) }}

-  Make values optional, for example:

   .. code-block:: jinja

      {%- if 'cheaper' in entry.uwsgi %}
      cheaper = {{ entry.uwsgi.cheaper }}
      {%- endif %}

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
