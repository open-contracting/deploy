Learn Salt
==========

We use `Salt <https://docs.saltstack.com/en/latest/>`__ (a.k.a. SaltStack) to deploy apps to servers, and to otherwise manage servers.

We use `Agentless Salt <https://docs.saltstack.com/en/getstarted/ssh/index.html>`__ (i.e. using the ``salt-ssh`` command). This avoids having to run Salt minions on servers, and requires only SSH to connect to the server and Python to run operations on it.

To orient you to the repository: When you run the ``./run.py`` script, it calls the ``salt-ssh`` command, which reads ``Saltfile``, which directs it to read the ``salt-config`` directory. ``salt-config/master`` directs it to read the ``salt`` and ``pillar`` directories. The ``top.sls`` file in each directory serves as an index to the other SLS files, which in turn refer to the files in sub-directories.

Read the :doc:`style/index` before editing this repository.

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
