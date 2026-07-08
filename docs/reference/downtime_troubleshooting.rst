Downtime Troubleshooting
========================

.. seealso::

   :ref:`Configured downtime notifications <alert-notifications>`

Common Diagnostics
==================

System Services
---------------

See all failed services.
This is good to run following a reboot to double check services have all come online again successfully.

.. code-block:: bash

   systemctl --failed


Get single service information, for example apache2:

.. code-block:: bash

   systemctl status apache2.service
   journalctl -u apache2.service
   journalctl -u apache2.service –since “2 days ago”


.. _system-logs:

System logs are accessible via journalctl -u example.service
They are also directly readable in /var/log

Notably:

- All system alerts: /var/log/syslog
- Apache website: /var/log/apache2
- NGINX site logs: /var/log/nginx
- Docker containers: /var/log/docker-custom


Docker Applications
-------------------

View all container status

.. code-block:: bash

   docker ps -a

View all container status, for example cove-ocds:

.. code-block:: bash

   sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml ps -a


Logs and debugging

All container logs are in stored in: `/var/log/docker-custom/`


.. _grafana:

System Resource usage
---------------------

System resources are reported into prometheus, the configured dashboards provide a quick and interactable display for this information. This can then be filtered down by server and time.
During an outage system resources are good to review, helping point to bottlenecks.
Also consider comparing system resources over a long timeframe to see normal utilisation.
https://grafana.prometheus.open-contracting.org/d/1864308e-eb04-4ded-bbea-c6188e502f11/single-server-monitoring

High CPU
~~~~~~~~
View processes sorted by CPU utilization

.. code-block:: bash

   top


High Memory
~~~~~~~~~~~

View processes sorted by Memory utilization

.. code-block:: bash

   top # Then press M

View total memory and used memory

.. code-block:: bash

   free -h


High Disk Space
~~~~~~~~~~~~~~~

View total disk space

.. code-block:: bash

   df -h

View disk usage of a directory and its contents

.. code-block:: bash

   du -h --max-depth=1 /path/to/directory


Network Attacks
---------------

Denial of Service (DOS) attacks are common causes of downtime, this is when a service, is overwhelmed with requests and cannot serve new traffic. You can identify a DOS attack by :ref:`looking at the logs<system-logs>`, here you will see a single IP address sending many of requests over a long consistent amount of time.
A Distributed Denial of Service (DDOS) is similar however traffic is coming from multiple IP addresses making it much more difficult to mitigate.
DOS attacks are not necessarily malicious, we have seen search engines and SEO companies crawl sites and inadvertently overwhelm the server causing an outage. Our response will depend on the legitimacy of the traffic and its impact.

Changes and deployments
-----------------------

Changes can cause downtime, two common examples of this are: updating software and it failing to start without new config options being set, or a typo in a configuration preventing a service from starting after a restart.
Configuration changes (new settings and changes to values) are all committed to GitHub and deployed via Salt.
You can see `recent commits in GitHub<https://github.com/open-contracting/deploy/commits/main/>`__.


Software updates are logged on the server.

View recent software patches and changes:

.. code-block:: bash

   less /var/log/apt/history.log


System changes should be implemented through SaltStack however smaller temporary changes can be made manually.
You can see the actions of previous users on the system with the following commands:

View currently, logged in users:

.. code-block:: bash

   w


View recent users:

.. code-block:: bash

   last

View run commands:

.. note::

   If another user is currently logged in their history will not be written yet.

.. code-block:: bash

   history

If there is not a clear fix to bring up the service following the change, or it takes longer than expected, revert the code or software to the previous working version.

Service Provider
----------------

Most ISPs provide status pages, here you can view the overall status of their network.
Often our monitoring will alert before ISPs have had a chance to respond, if it does seem like an ISP issue and there is no information yet then reach out via their support system raising an urgent request.

These are the relevant status pages for our infrastructure hosting:

- https://www.cloudflarestatus.com/
- https://status.linode.com/
- https://status.hetzner.com/

Network outage or server is inaccessible
----------------------------------------

In the situation where a server is offline or inaccessible you are limited in the diagnostic steps you can take. These are places you can check without SSH access and the information they give you:

- Does any website / endpoint respond?
  - Confirming whether the issue is affecting the whole server or limited to a service / application.
- Check resources in :ref:`Grafana<grafana>`
  - How recent is the data? This shows if the outbound networking is working.
  - This can also lead to the problem, maxed CPU or Memory usage will affect the speed of the SSH service.
- Are you blocked by the firewall?
  - Is there an external firewall blocking you?
  - Have you port knocked? (on non-docker servers)

If the server is inaccessible and completely offline you may need to jump to :ref:`restarting the server via the ISP<isp-reboot>`.

Linode Physical Host Outage
~~~~~~~~~~~~~~~~~~~~~~~~~~~

We have seen the occasional issue with the underlying physical host running our VPS taking fault, this has then taken the OCP server(s) offline and prevent the Linode admin interface from responding. If the issue is limited to only one host this will not be posted on the public Linode Status Page, instead we will be contacted directly on a support ticket. This support ticket will set expectations of how Linode will be responding to the issue and timescales for a resolution.


Common Solutions
================

System Services
---------------
Restarting services, for example apache2:

.. code-block:: bash

   systemctl restart apache2.service


Docker Applications
-------------------

Restart application, for example cove-ocds:

.. code-block:: bash

   sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml pull
   sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml down
   sudo -u deployer docker compose -f /data/deploy/cove-ocds/docker-compose.yaml up -d


When running `docker compose up -d` by Docker automatically updates and pulls the latest container images, however this significantly increases downtime so we prefer to pull images in advance.


Downgrade Software
------------------

List available versions and install a specific software version, for example Apache:

.. code-block:: bash

   apt-cache policy apache2
   apt-get install apache2:1.2.3


.. _isp-reboot:

Force system reboot
-------------------

If you cannot SSH into a server and reboot normally (reboot), you can force a reboot via the ISP interface.

Linode:

#. Log in: https://login.linode.com/login
#. Select the server, "..." > "Reboot"

Hetzner:

#. Log in: https://robot.hetzner.com/server
#. Server
#. Select the server > "Reset"
#. "Press power button of server", Send
   #. The server will take a minute to process and react.
   #. If the Hetzner server has not responded to the power off signal in a minute, then escalate to a "Long power button press".
#. Wait until the current status is powered off and start the server again. "Press power button of server", Send


Blocking an IP address
----------------------

.. note::

   Most web traffic is proxied through Cloudflare, double check the problem IP you have identified is not a Cloudflare IP before blocking it.

Block an IP in IPTables
~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   IPTables is disabled on servers running Docker.

Block an IP address server-wide.

#. Edit `/home/sysadmin-tools/firewall-settings.local` and set the DENY settings, for example:

   .. code-block:: bash

      DENYALL_IPV4="192.0.2.1 192.0.2.4"
      DENYALL_IPV6="2001:db8::/64"

#. Then re-run the firewall /home/sysadmin-tools/bin/firewall.sh

Block an IP in Cloudflare
~~~~~~~~~~~~~~~~~~~~~~~~~

Block an IP address accessing any website on the selected domain, for example blocking 192.0.2.1:

#. Log into `Cloudflare<https://dash.cloudflare.com>`__
#. Select the "Open Contracting" Account
#. Domains > Overview
#. Select your domain, normally open-contracting.org for public facing sites.
#. Security > Security Rules > New custom rule
   #. Rule name: Block 192.0.2.1
   #. When incoming requests match…
      #. Field: IP Source Address
      #. Value 192.0.2.1
   #. Take action: Block
   #. Deploy

Cloudflare Under Attack Mode
----------------------------

.. note::

   This operates at a domain level screening traffic to all sites regardless of where they are hosted.

Limits and challenges traffic visiting the domain through a non-interactive challenge screen.
This is best for handling large scale attacks such as a DDOS.

#. Log into `Cloudflare<https://dash.cloudflare.com>`__
#. Select the "Open Contracting" Account
#. Domains > Overview
#. Select your domain
#. "Quick Actions", toggle "Under Attack Mode"

Total Server Loss
-----------------

In the rare circumstance of a total server loss the only option is to rebuild a new server and recover data from backups.

#. Create new server
   #. https://ocdsdeploy.readthedocs.io/en/latest/deploy/create_server.html
   #. Either use the latest supported operating system image or the version used on the previous server. Using the latest image may require additional configuration changes.
   #. You will have a new IP address so create a new hostname and update the pillar data accordingly.
#. Recover data from backups
   #. Backup data location and purpose can be gathered from
   #. https://ocdsdeploy.readthedocs.io/en/latest/maintain/backup.html
#. Go live
   #. Test the site by updating your local hosts file
   #. Update DNS
