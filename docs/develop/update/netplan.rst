Configure networking
====================

There are two ways to configure Netplan using the ``core.network`` Salt state file. For most servers the :ref:`templated option<Netplan Template>` is easiest approach, if you require advanced configuration options see :ref:`Netplan Custom`.

Template
--------

The templated option has been designed specifically for Linode servers, it disables automatic IP configuration (DHCP) and sets up static networking on IPv4 and IPv6.

   .. note::

      We use static networking in order to configure IPv6 correctly on Linode servers. By default, Linode servers will listen and prefer IPv6 traffic on the servers default IPv6 address, we however want to use our own IPv6 block. This has the benefits of ensuring a good IP reputation and improving email deliverability.

Example configuration based on OCP14:

   .. code-block:: yaml

      network:
        netplan: True
        ipv4:
          primary_ip: 139.162.199.85
          primary_ip_subnet_mask: "/24"
          gateway_ip: 139.162.199.1
          dns_servers: [ 178.79.182.5, 176.58.107.5, 176.58.116.5, 176.58.121.5, 151.236.220.5, 212.71.252.5, 212.71.253.5, 109.74.192.20, 109.74.193.20, 109.74.194.20 ]
        ipv6:
          primary_ip: 2a01:7e00:e000:02cc::14
          primary_ip_subnet_mask: "/128"
          slaac_ip: 2a01:7e00::f03c:92ff:fea5:0e5f/128
          gateway_ip: fe80::1
          dns_servers: [ 2a01:7e00::9, 2a01:7e00::3, 2a01:7e00::c, 2a01:7e00::5, 2a01:7e00::6, 2a01:7e00::8, 2a01:7e00::b, 2a01:7e00::4, 2a01:7e00::7, 2a01:7e00::2 ]
        search_domain: open-contracting.org

netplan
   Enables the template Netplan configuration. Default Value: ``False``.
primary_ip
   Configure the primary IP addresses, this IP is also configured elsewhere on the system.
primary_ip_subnet_mask
   Default Value: ``/32`` for IPv4 and ``/128`` for IPv6.
gateway_ip
   "Default Gateway" to route network traffic through.
dns_servers
   List of DNS Resolvers.
slaac_ip
   "StateLess Address Auto Configuration" (SLAAC) helps with automatic network configuration. Linode requires SLAAC to be configured. IPv6 only option.
search_domain
   Configure search domain for host look-ups. Default Value: ``open-contracting.org``.

If you provisioned the server in Linode these configuration values can be found in the Linode interface under the *Network* tab.

Custom
------

Example Configuration based on OCP13:

   .. code-block:: yaml

      network:
        ipv4:
          primary_ip: 65.21.93.181
        ipv6:
          primary_ip: 2a01:4f9:3b:45ca::2
        custom_netplan:
          network:
            version: 2
            renderer: networkd
            ethernets:
              enp9s0:
                addresses:
                  - 65.21.93.181/32
                  - 65.21.93.141/32
                  - 2a01:4f9:3b:45ca::2/64
                routes:
                  - on-link: true
                    to: 0.0.0.0/0
                    via: 65.21.93.129
                gateway6: fe80::1
                nameservers:
                  addresses:
                    - 213.133.99.99
                    - 213.133.100.100
                    - 213.133.98.98
                    - 2a01:4f8:0:1::add:9898
                    - 2a01:4f8:0:1::add:9999
                    - 2a01:4f8:0:1::add:1010

primary_ip
   Configure the primary IP addresses on the system.
custom_netplan
   Parse your Netplan configuration, this is serialized as yaml and uploaded to ``/etc/netplan/10-salt-networking.yaml``
