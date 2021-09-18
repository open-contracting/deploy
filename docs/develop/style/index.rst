Style guides
============

.. toctree::

   language.rst
   salt.rst
   configuration.rst

grains
------

To make Pillar, state and configuration files more reusable, use `Grains <https://docs.saltstack.com/en/latest/topics/grains/>`__ where possible. Common grains with example values are:

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

Pillar
------

Order the top-level keys in these layers:

-  Meta
  -  System administration: ``maintenance``, ``system_contacts``
  -  Third-party service credentials: ``github``, ``google``, ``smtp``
-  Universal services
  -  Server access: ``firewall``, ``ssh``
  -  Kernel: ``vm``
  -  Monitoring: ``prometheus``
  -  Logging: ``rsyslog``, ``logrotate``
-  Application services
  -  Web access: ``apache``
  -  Services: ``elasticsearch``, ``postgres``, ``rabbitmq``
  -  Environments: ``docker``, ``nodejs``
  -  Applications: ``docker_apps``, ``python_apps``, ``react_apps``
