Configure networking
====================

Hostnames and IP addresses
--------------------------

Update the server's Pillar file:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: 2001:db8::12

``ipv6`` is optional.

Netplan
-------

`Netplan <https://netplan.io>`__ uses YAML files for configuration. Configurations are available for Linode and other hosts. The configuration is written to ``/etc/netplan/10-salt-networking.yaml``.

Linode
~~~~~~

This configuration disables automatic IP configuration and configures static networking on IPv4 and IPv6.

.. note::

   By default, a Linode server listens on – and prefers traffic to – its default IPv6 address. We use our own IPv6 block – ``2a01:7e00:e000:02cc::/64`` – to improve IP reputation and email deliverability.

.. admonition:: One-time setup

   `Open a support ticket with Linode <https://cloud.linode.com/support/tickets>`__ to request an IPv6 /64 block:

      Hello,

      Please provision an IPv6 /64 block for our account.

      Thank you,

   A /64 block is requested, because `spam blocklists use /64 ranges <https://www.spamhaus.org/organization/statement/012/spamhaus-ipv6-blocklists-strategy-statement>`__.

Update the server's Pillar file:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: 2001:db8::12
     netplan:
       template: linode
       addresses:
         - 2001:db8::32/64    # SLAAC
       gateway4: 198.51.100.1
       gateway6: fe80::1

To fill in the above, from the *Network* tab on the `Linode's <https://cloud.linode.com/linodes>`__ page, collect:

``ipv4``
  The *Address* with a *Type* of *IPv4 – Public*
``addresses``
  The *Address* with a *Type* of *IPv6 – SLAAC*, `suffixed by "/64" <https://www.linode.com/docs/guides/linux-static-ip-configuration/#general-information>`__
``gateway4``
  The *Default Gateway* with a *Type* of *IPv4 – Public*
``gateway6``
  The *Default Gateway* with a *Type* of *IPv6 – SLAAC*

For ``ipv6``, use our IPv6 block with the hostname's digits as the final group of the IPv6 address: for example, *2a01:7e00:e000:02cc::12* for *ocp12*.

Other hosting providers
~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   This step is optional. Only override a Netplan configuration if necessary. For example, Hetzner's `installimage <https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/>`__ script creates a `configuration file <https://github.com/hetzneronline/installimage/blob/84883efa372b9c9ecef2bb7703d696221b4e1093/network_config.functions.sh#L560>`__.

In the server's Pillar file, set ``network.netplan.template`` to ``custom`` and set ``network.netplan.configuration``:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: 2001:db8::12
     netplan:
       template: custom
       configuration: |
         network:
           version: 2
           renderer: networkd
           ethernets:
             eth0:
               addresses:
                 - 198.51.100.34/32
                 ...

NTP Servers
-----------

NTP configures and maintains time on the servers, this is installed and configured automatically by Salt.

By default servers are configured to use the UK NTP pool, if your server is located outside of the UK it is advisable to choose NTP servers from the servers geographical region.

We do this to reduce network latency to the NTP source providing a more reliable source of time.

You can configure custom NTP servers by editing the server's Pillar file and configuring ``ntp`` to a list of the desired `NTP servers <https://www.pool.ntp.org/zone/europe>`__.

For example to use the NTP servers located in Finland:

.. code-block:: yaml

   ntp:
     - 0.fi.pool.ntp.org
     - 1.fi.pool.ntp.org
     - 2.fi.pool.ntp.org
     - 3.fi.pool.ntp.org
