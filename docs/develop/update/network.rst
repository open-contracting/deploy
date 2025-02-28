Configure networking
====================

Hostnames and IP addresses
--------------------------

Update the server's Pillar file. For example:

.. code-block:: yaml

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: 2001:db8::12

``ipv6`` is optional.

Time servers
------------

`systemd-timesyncd <https://www.man7.org/linux/man-pages/man8/systemd-timesyncd.8.html>`__ synchronizes the local system clock with remote `NTP <https://en.wikipedia.org/wiki/Network_Time_Protocol>`__ servers.

You should select NTP servers from the `NTP Pool Project <https://www.ntppool.org/zone/@>`__ that are close to the server's location, in order to mitigate network latency and improve time accuracy.

For example, to use the `NTP servers in Finland <https://www.ntppool.org/zone/fi>`__, add to the server's Pillar file:

.. code-block:: yaml

   ntp:
     - 0.fi.pool.ntp.org
     - 1.fi.pool.ntp.org
     - 2.fi.pool.ntp.org
     - 3.fi.pool.ntp.org

By default, the NTP servers in the UK are used.

Linux networking
----------------

.. note::

   This step is required on Linode if *Auto-configure networking* was unchecked in :doc:`../../deploy/create_server`.

systemd-networkd
~~~~~~~~~~~~~~~~

`systemd-networkd <https://manpages.ubuntu.com/manpages/jammy/man5/systemd.network.5.html>`__ is a system daemon to configure networking, and is our preferred solution for Linode instances. The configuration is written to ``/etc/systemd/network/05-eth0.network``. A configuration template is available for Linode.

Linode template
^^^^^^^^^^^^^^^

This configuration disables automatic IP configuration and configures static networking on IPv4 and IPv6.

.. note::

   By default, a Linode server listens on – and prefers traffic to – its default IPv6 address. We provision IPv6 /64 blocks for each server to improve IP reputation and email deliverability.

.. admonition:: Email template

   `Open a support ticket with Linode <https://cloud.linode.com/support/tickets>`__ to request an IPv6 /64 block, replacing ``ocpXX`` with the Linode instance's ID:

      Hello,

      Please can you provision an IPv6 /64 block for my server ocpXX.open-contracting.org.

      Thank you,

   A /64 block is requested, because `spam blocklists use /64 ranges <https://web.archive.org/web/20221217212321/https://www.spamhaus.org/organization/statement/12/spamhaus-ipv6-blocklists-strategy-statement>`__.

Update the server's Pillar file. For example:

.. code-block:: yaml
   :emphasize-lines: 5-9

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: "2001:db8::"
     networkd:
       template: linode
       gateway4: 198.51.100.1
       addresses:
         - 2001:db8::/64

To fill in the above, from the *Network* tab on the `Linode's <https://cloud.linode.com/linodes>`__ page, collect:

``ipv4``
  The *Address* with a *Type* of *IPv4 – Public*
``gateway4``
  The *Default Gateway* with a *Type* of *IPv4 – Public*
``addresses``
  Other IP addresses attached to your instance (if any). Include the subnet block suffix, e.g.: `/64`

Custom template
^^^^^^^^^^^^^^^

.. warning::

   Only use a ``custom`` template if your needs are not met by any other template.

Update the server's Pillar file. For example:

.. code-block:: yaml
   :emphasize-lines: 5-22

   network:
     host_id: ocp12
     ipv4: 198.51.100.34
     ipv6: "2001:db8::"
     networkd:
       template: custom
       network.networkd.configuration: |
         [Match]
         Name=eth0

         [Network]
         DHCP=no
         DNS=203.0.113.1 203.0.113.2 2001:db8::32 2001:db8::64
         Domains=open-contracting.org
         IPv6PrivacyExtensions=false
         IPv6AcceptRA=false

         Address=198.51.100.34/24
         Address=2001:db8::12/64

         Gateway=Address=198.51.100.1
         Gateway=fe80::1

Netplan
~~~~~~~

`Netplan <https://netplan.io>`__ uses YAML files for configuration. The configuration is written to ``/etc/netplan/10-salt-networking.yaml``. A configuration template is available for Linode.

.. note::

   This step is optional. Only override a Netplan configuration if necessary. For example, Hetzner's `installimage <https://docs.hetzner.com/robot/dedicated-server/operating-systems/installimage/>`__ script creates a `configuration file <https://github.com/hetzneronline/installimage/blob/84883efa372b9c9ecef2bb7703d696221b4e1093/network_config.functions.sh#L560>`__ that works as-is.

Update the server's Pillar file. For example:

.. code-block:: yaml
   :emphasize-lines: 5-15

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

If setting ``nameservers:``, use `Hetzner <https://docs.hetzner.com/dns-console/dns/general/recursive-name-servers/>`__, `Cloudflare <https://developers.cloudflare.com/1.1.1.1/ip-addresses/>`__, and `OpenDNS <https://support.opendns.com/hc/en-us/articles/360052884932-OpenDNS-Self-Help-Troubleshooting-Guide#computer>`__ resolvers.

.. DNSRESOLVER and DNSRESOLVER_V6 in https://github.com/hetzneronline/installimage/blob/master/config.sh
