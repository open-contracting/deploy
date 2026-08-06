Troubleshoot downtime
=====================

This page describes diagnostics and solutions.

.. seealso:: :ref:`downtime-alerts`

Inaccessible server
-------------------

If you can't SSH into the server:

-  Have you **port knocked**? (if the server isn't using Docker)
-  Is the **external firewall** blocking you?
-  Is the **server's firewall** blocking you?
-  Does any website or endpoint **respond**?

   -  This confirms whether the issue affects the whole server or is limited to one service.

-  How **recent** is the :ref:`Grafana<grafana>` data?

   -  This confirms whether outbound networking is working.

- Is resource usage **high** in :ref:`Grafana<grafana>`?

  - Maxed CPU or memory usage can affect the performance of the SSH service.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Force system reboot
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   .. tab-set::

      .. tab-item:: Linode

         #. `Log into Linode <https://login.linode.com/login>`__
         #. Click the server label
         #. Click the *... > Reboot* menu item

      .. tab-item:: Hetzner

         #. `Log into Hetzner Robot <https://robot.hetzner.com/server>`__
         #. Click the *Server* left-hand menu item
         #. Click the Server ID
         #. Click the *Reset* tab
         #. Power off the server

            #. Check *Press power button of server* 
            #. Click the *Send* button

         #. After a minute, if the server hasn't responded to the button press:

            #. Check *Long power button press*
            #. Click the *Send* button

         #. Wait until the *Current status* is "Powered off"
         #. Power on the server

            #. Check *Press power button of server* 
            #. Click the *Send* button

System resources
----------------

Solutions to high resource utilization vary, from application updates to configuration changes.

Dashboard
~~~~~~~~~

See :doc:`../use/prometheus`. You typically:

#. Select the server
#. Narrow the time to the outage
#. Check system resources over a longer timeframe, to compare to normal utilization

CPU
~~~

-  View processes sorted by CPU utilization:

   .. code-block:: bash

      top

Memory
~~~~~~

-  View processes sorted by memory utilization:

   .. code-block:: bash

      top # then press M

-  View total memory and used memory:

   .. code-block:: bash

      free -h

Disk space
~~~~~~~~~~

-  View total disk space:

   .. code-block:: bash

      df -h

-  View disk usage of a directory and its contents:

   .. code-block:: bash

      du -h --max-depth=1 /path/to/directory

System services
---------------

-  List failed services:

   .. code-block:: bash

      systemctl --failed

   .. tip:: Run this after a reboot, to double-check all services have started successfully.

-  Get one service's status, for example:

   .. code-block:: bash

      systemctl status apache2.service

.. _downtime-logs:

-  Get one service's log, for example:

   .. code-block:: bash

      journalctl -u apache2.service
      journalctl -u apache2.service --since "2 days ago"


-  Read logs from ``/var/log`` directly, notably:

   - System log: ``/var/log/syslog``
   - Apache: ``/var/log/apache2``
   - Nginx: ``/var/log/nginx``
   - Docker containers: ``/var/log/docker-custom``

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Restart the service
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   For example:

   .. code-block:: bash

      systemctl restart apache2.service

   If it still fails, see: :ref:`downtime-updates`

Docker applications
-------------------

-  List all containers:

   .. code-block:: bash

      docker ps -a

-  List all containers for a Docker Compose file, for example:

   .. code-block:: bash

      sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml ps -a

-  Read container logs in ``/var/log/docker-custom/``

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Restart the containers
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   If newer images fix the diagnosed issue, pull all images:

   .. code-block:: bash

      sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml pull

   If a service was removed, the network was reconfigured, a bind-mounted configuration file changed, or things are otherwise in a bad state, stop and remove containers and networks:

   .. code-block:: bash

      sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml down

   Then, restart all containers for a Docker Compose file:

   .. code-block:: bash

      sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml up -d

   .. note::

     `"The 'latest' tag is always pulled even when the 'missing' pull policy is used." <https://docs.docker.com/reference/compose-file/services/#pull_policy>`__

.. _downtime-updates:

Configuration changes
---------------------

Changes can cause downtime. Two common examples:

-  A typo in an updated configuration file prevents the service from starting
-  An updated service fails to start due to now-obsolete or missing configuration options

To diagnose:

-  Read `recent commits <https://github.com/open-contracting/deploy/commits/main/>`__ to the ``deploy`` repository
-  Read recent software patches and changes:

   .. code-block:: bash

      less /var/log/apt/history.log

-  List logged-in users, who might have made changes directly:

   .. code-block:: bash

      w

-  List recent users:

   .. code-block:: bash

      last

-  List recent commands:

   .. code-block:: bash

      history

   .. note:: If a user is currently logged in, their history will not be written yet.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Revert the changes
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   If a solution is unknown, or is taking too long, revert to the previous working version.

   -  List available versions and install a specific version, for example:

      .. code-block:: bash

         apt-cache policy apache2
         apt-get install apache2:1.2.3

DOS attacks
-----------

`Denial-of-service (DOS) attacks <https://en.wikipedia.org/wiki/Denial-of-service_attack>`__ can cause downtime.

Heavy traffic is not necessarily a DOS attack; web crawlers can inadvertently overwhelm a server. Our response depends on the legitimacy of the traffic and its impact.

You can identify a DOS attack by :ref:`reading the logs<downtime-logs>` and seeing a single IP address send many requests at high frequency.

.. attention::

   Most web traffic is proxied through Cloudflare. Before blocking an IP, check that it's not a Cloudflare IP.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Block an IP address in iptables
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   .. note::

      iptables is disabled on servers running Docker.

   #. Edit ``/home/sysadmin-tools/firewall-settings.local``, for example:

      .. code-block:: bash

         DENYALL_IPV4="192.0.2.1 192.0.2.4"
         DENYALL_IPV6="2001:db8::/64"

   #. Update the iptables rules:

      .. code-block:: bash

         /home/sysadmin-tools/bin/firewall.sh

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Block an IP address in Cloudflare
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   Block an IP address from accessing any server on the entire domain, for example:

   #. `Log into Cloudflare <https://dash.cloudflare.com>`__
   #. Select the "Open Contracting" account
   #. Click the *Domains > Overview* menu item
   #. Click the domain (e.g. "open-contracting.org")
   #. Click the *Security > Security rules* menu item
   #. Click the *Create rule* button in the *Custom rules* panel

      #. *Rule name:* Block 192.0.2.1
      #. *When incoming requests match…*

         #. *Field:* IP Source Address
         #. *Value:* 192.0.2.1

      #. *Then take action…:* Block
      #. Click the *Deploy* button

DDOS attacks
------------

A distributed denial-of-service (DDOS) attack is harder to mitigate, because traffic originates from multiple IP addresses.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Cloudflare Under Attack mode
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   This affects the entire domain.

   #. `Log into Cloudflare <https://dash.cloudflare.com>`__
   #. Select the "Open Contracting" account
   #. Click the *Domains > Overview* menu item
   #. Click the domain (e.g. "open-contracting.org")
   #. Toggle `Under Attack Mode <https://developers.cloudflare.com/fundamentals/reference/under-attack-mode/>`__ under *Quick Actions*

Service provider incidents
--------------------------

-  Check the service provider's :ref:`status page<hosting>`

   .. admonition:: Linode physical host outage

      If an issue is limited to one physical host (e.g. hardware issue), the status page will not update. Instead, Linode will contact us via a support ticket that explains how Linode is responding and sets expectations for resolution time.

      A symptom of a physical host outage is a server not responding to *Power Off* or *Reboot* actions.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Open a support ticket
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   Our alerts often fire before the service provider updates its status page. If it nonetheless seems like a service provider issue, open an urgent support ticket with the service provider.

.. card::
   :class-header: sd-font-weight-bold sd-bg-success sd-bg-text-success

   Solution: Rebuild the server
   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

   In the rare event of a total loss, create a new server and recover from backups:

   #. `Create a new server <https://ocdsdeploy.readthedocs.io/en/latest/deploy/create_server.html>`__ and hostname, using the same OS version as the previous server
   #. Update any configurations in the ``deploy`` repository that use the old hostname or IP address
   #. `Recover from backups <https://ocdsdeploy.readthedocs.io/en/latest/maintain/backup.html>`__
   #. Preview and test the services on the server, by updating your ``/etc/hosts`` file
   #. `Update DNS records <http://localhost:8001/deploy/services/cloudflare.html#dns>`__
