Configure networking
====================

Hostnames and IP addresses
--------------------------

Update the server's Pillar file:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 123.45.67.89
     ipv6: 2001:db8:0:1

``ipv6`` is optional.

Netplan
-------

`Netplan <https://netplan.io>`__ uses YAML files for configuration. Configurations are available for Linode and other hosts. The configuration is written to ``/etc/netplan/10-salt-networking.yaml``.

Linode
~~~~~~

This configuration disables automatic IP configuration and configures static networking on IPv4 and IPv6.

.. note::

   By default, a Linode server listens on – and prefers traffic to – its default IPv6 address. We use our own IPv6 block, to improve IP reputation and email deliverability.

Update the server's Pillar file:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 123.45.67.89
     ipv6: 2001:db8:0:1
     netplan:
       configuration: linode
       ipv4_subnet_mask: "/24"
       ipv6_subnet_mask: "/128"
       addresses:
         - 2a01:7e00::f03c:92ff:fea5:0e5f/128  # SLAAC
       gateway4: 139.162.199.1
       gateway6: fe80::1
       nameservers:
         addresses: [ 1.2.3.4, 5.6.7.8, 2001:db8:0:1, 2001:db8:0:2 ]
         search:
          - open-contracting.org

To fill in the above, from the *Network* tab on the `Linode's <https://cloud.linode.com/linodes>`__ page, collect:

``ipv4``
  The *Address* with a *Type* of *IPv4 – Public*
``ipv6``
  TODO
``ipv4_subnet_mask``
  TODO, default "/32"
``ipv6_subnet_mask``
  TODO, default "/128"
``addresses``
  The *Address* with a *Type* of *IPv6 – SLAAC*, suffixed by "/128"
``gateway4``
  The *Default Gateway* with a *Type* of *IPv4 – Public*
``gateway6``
  The *Default Gateway* with a *Type* of *IPv6 – SLAAC*
``nameservers.addresses``
  The *DNS Resolvers*
``nameservers.search``
  Default ``open-contracting.org``

Other hosts
~~~~~~~~~~~

In the server's Pillar file, set ``network.netplan.configuration`` to ``custom`` and set ``network.netplan.ethernets``:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 123.45.67.89
     ipv6: 2001:db8:0:1
     netplan:
       configuration: custom
       ethernets:
         eth0:
            # Your Netplan configuration for the eth0 device.
