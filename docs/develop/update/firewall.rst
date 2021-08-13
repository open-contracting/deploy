Configure firewall
==================

.. note:::

   The below firewall configuration doesn't work with Docker. :ref:`See below for alternative solutions<Docker Servers>`.

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
-----------

If no variable corresponds to the port you need to open, update the ``firewall.sh`` script and ``firewall-settings.local`` template.

You might need to set variables if you're working in a development environment. To set a variable, use the ``set_firewall`` macro, for example:

   .. code-block:: yaml

      {{ set_firewall("PUBLIC_SSH") }}

This sets ``PUBLIC_SSH="yes"`` in the ``firewall-settings.local`` file.

Close a port
------------

Use the :ref:`unset_firewall macro<delete-firewall-setting>` if a ``set_firewall`` call is removed from a service's state, whether directly (by deleting a ``set_firewall`` call) or indirectly (by un-including a state file with ``set_firewall`` calls).

Troubleshoot
------------

When making changes to firewall settings or port assignments, you might want to:

-  Check if a port is open:

   .. code-block:: bash

      telnet host port

-  List active connections:

   .. code-block:: bash

      netstat -tupln

Docker Servers
==============

Docker manipulates IPTables to route network traffic to and from containers this interferes with our firewall management script. To prevent errors saltstack and the firewall script identify docker and block the script from running. To work around this on servers hosting Docker we need to implement an alternative firewall solution that is configured external to the instance.

Hetzner (Hardware Servers)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Hetzner provide a simple stateless firewall with each server. "Stateless" means that the firewall does not track connections, it simply monitors all inbound and outbound traffic by IP and ports in that moment.

You can configure the Hetzner firewall as follows:

#. `Log into Hetzner <https://robot.your-server.de/server>`__
#. Select your server and go to the *Firewall* tab
#. Set *Status* to active
#. Enable *Hetzner Services*
#. Create your firewall rules

   We recommend the following rules as a minimum

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

.. Note:::

   `More information can be found in the Hetzner documentation.<https://docs.hetzner.com/robot/dedicated-server/firewall/>`__

Linode (VPS Servers)
~~~~~~~~~~~~~~~~~~~~

Linode provide a stateful Cloud Firewall. Stateful firewalls track connections for you making configuration easier.

You can configure a Linode Cloud Firewall as follows:

#. `Log into Linode <https://login.linode.com/>`__
#. Open the `*Firewalls* listing page<https://cloud.linode.com/firewalls>`__
#. Click *Create Firewall*

   #. Set *Label* to the server name
   #. Assign your Linode instance

#. Select your new Firewall
#. Set *Default inbound policy* to *Drop*
#. Add an Inbound Rule

   We recommend the following rules as a minimum

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

#. Click *Save Changes*

.. Node:::

   `More information can be found in the Linode documentation.<https://www.linode.com/docs/guides/getting-started-with-cloud-firewall/>`__
