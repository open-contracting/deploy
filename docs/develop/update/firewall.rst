Configure firewall
==================

When not using Docker
---------------------

The `firewall.sh script <https://github.com/open-contracting/deploy/blob/main/salt/core/firewall/files/firewall.sh>`__ closes most ports by default. Its behavior is controlled by variables in the `firewall-settings.local file <https://github.com/open-contracting/deploy/blob/main/salt/core/firewall/files/firewall-settings.local>`__.

Most variables are set by state files:

SSH_IPV4 and SSH_IPV6
  IPs from which to allow SSH collections. Set by the ``firewall`` state using Pillar data. See :doc:`../../use/ssh`.
PUBLIC_HTTP
  Opens port 80. Set by the ``apache`` state.
PUBLIC_HTTPS
  Opens port 443. Set by the ``apache`` state.
PUBLIC_POSTGRESQL
  Opens port 5432. Set by the ``postgres`` state, if ``postgres.public_access`` is ``True`` in Pillar.
PRIVATE_POSTGRESQL
  Opens port 5432 to the replica servers. Set by the ``postgres`` state, if ``postgres.public_access`` isn't ``True`` in Pillar.
REPLICA_IPV4 and REPLICA_IPV6
  The IPs of replica servers. Set by the ``postgres`` state using Pillar data, if ``postgres.public_access`` isn't ``True`` in Pillar.
PUBLIC_ELASTICSEARCH
  Opens port 9200. Set by the ``elasticsearch`` state.
PUBLIC_TINYPROXY
  Opens port 8888. Set by the ``tinyproxy`` state.
PRIVATE_PROMETHEUS_CLIENT
  Opens port 7231 to the Prometheus server. Set by the ``prometheus.node_exporter`` state.
PROMETHEUS_IPV4 and PROMETHEUS_IPV6
  The IPs of the Prometheus server. Set by the ``prometheus.node_exporter`` state using Pillar data.

Other variables are:

PUBLIC_SSH
  Opens port 22. Supersedes :doc:`port knocking<../../use/ssh>`.

Open a port
~~~~~~~~~~~

If no variable corresponds to the port you need to open, update the ``firewall.sh`` script and ``firewall-settings.local`` template.

You might need to set variables if you're working in a development environment. To set a variable, use the ``set_firewall`` macro, for example:

   .. code-block:: yaml

      {{ set_firewall("PUBLIC_SSH") }}

This sets ``PUBLIC_SSH="yes"`` in the ``firewall-settings.local`` file.

Close a port
~~~~~~~~~~~~

Use the :ref:`unset_firewall macro<delete-firewall-setting>` if a ``set_firewall`` call is removed from a service's state, whether directly (by deleting a ``set_firewall`` call) or indirectly (by un-including a state file with ``set_firewall`` calls).

Troubleshoot
~~~~~~~~~~~~

When making changes to firewall settings or port assignments, you might want to:

-  Check if a port is open:

   .. code-block:: bash

      telnet host port

-  List active connections:

   .. code-block:: bash

      netstat -tupln

When using Docker
-----------------

The `firewall.sh` script rewrites all iptables rules. However, Docker needs to add rules to route traffic to and from containers. To address this incompatibility, the `firewall.sh` script exits if the `docker` command exists. To implement firewall rules on Docker servers, we implement an external firewall.

.. _hetzner-firewall:

Hetzner (hardware servers)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hetzner provide a free `stateless firewall <https://docs.hetzner.com/robot/dedicated-server/firewall/>`__ for each dedicated server. "Stateless" means that the firewall does not store information about connections over time, which is required for HTTP sessions and port knocking, for example.

You can configure a Hetzner firewall as follows:

#. `Log into Hetzner <https://robot.your-server.de/server>`__
#. Select your server and go to the *Firewall* tab
#. Set *Status* to active
#. Enable *Hetzner Services*
#. Create your firewall rules. The recommended minimum is:

   .. list-table::
      :header-rows: 1

      * - Name
        - Source IP
        - Destination IP
        - Source port
        - Destination port
        - Protocol
        - TCP flags
        - Action
      * - Allow SSH
        - 0.0.0.0/0
        - 0.0.0.0/0
        - 0-65535
        - 22
        - *
        -
        - Accept
      * - Allow ICMP
        - 0.0.0.0/0
        - 0.0.0.0/0
        - 0-65535
        - 0-65535
        - icmp
        -
        - Accept
      * - Allow Prometheus
        - 213.138.113.219/32
        - 0.0.0.0/0
        - 0-65535
        - 7231
        - *
        -
        - Accept
      * - Allow Outgoing TCP
        - 0.0.0.0/0
        - 0.0.0.0/0
        - 0-65535
        - 32768-65535
        - tcp
        - ack
        - Accept

.. _linode-firewall:

Linode (VPS servers)
~~~~~~~~~~~~~~~~~~~~

Linode provide a stateful `Cloud Firewall <https://www.linode.com/docs/guides/getting-started-with-cloud-firewall/>`__. Stateful firewalls can store information about connections over time, which is required for HTTP sessions and port knocking, for example.

You can configure a Linode Cloud Firewall as follows:

#. `Log into Linode <https://login.linode.com/>`__
#. Open the `Firewalls <https://cloud.linode.com/firewalls>`__ list
#. Click *Create Firewall*

   #. Set *Label* to the server name
   #. Set *Linodes* to the server
   #. Click *Create Firewall*

#. Click on the label for the new firewall

   #. Set *Default inbound policy* to *Drop*
   #. Add an inbound rule. The recommended minimum is:
   
      .. list-table::
         :header-rows: 1
   
         * - Label
           - Protocol
           - Ports
           - Sources
           - Action
         * - Allow-SSH
           - TCP
           - SSH (22)
           - All IPv4, All IPv6
           - Accept
         * - Allow-ICMP
           - ICMP
           -
           - All IPv4, All IPv6
           - Accept
         * - Allow-Prometheus
           - TCP
           - 7231
           - 213.138.113.219/32, 2001:41c8:51:7db::219/128
           - Accept
   
      Most servers will also have:
   
      .. list-table::
         :header-rows: 1
   
         * - Label
           - Protocol
           - Ports
           - Sources
           - Action
         * - Allow-HTTP
           - TCP
           - HTTP (80), HTTPS (443)
           - All IPv4, All IPv6
           - Accept

   #. Click *Save Changes*
