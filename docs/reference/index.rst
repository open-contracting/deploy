Reference
=========

This section of the documentation describes facts about our servers and deployments.

Monitoring
----------

UptimeRobot
~~~~~~~~~~~

Website downtime is monitored by `UptimeRobot <https://uptimerobot.com/>`__, which notifies sysadmin email addresses at OCP and ODS. Keyword monitors are used where possible.

Sentry
~~~~~~

Application errors are reported to `Sentry <https://sentry.io/>`__, which notifies individual email addresses. Not all services report errors to Sentry.

Prometheus
~~~~~~~~~~

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Salt is used to configure Prometheus monitoring on each server.

We use the following exporters:

-  `Node Exporter <https://github.com/prometheus/node_exporter>`__ is installed on each server to export hardware and OS metrics like disk space used, memory used, etc.
-  `Black Box Exporter <https://github.com/prometheus/blackbox_exporter>`__ is installed on the Prometheus server to check that services are up. (Keyword monitors are more complicated to configure than on UptimeRobot, and so are not used.)

Salt sets up a Prometheus server to collect metrics from these servers.

For access details, check the configuration file ``pillar/private/prometheus_pillar.sls``. You can find `OCP's verson of this here <https://github.com/open-contracting/deploy-pillar-private/blob/master/prometheus_pillar.sls>`__.

To access the monitoring service, go to the URL in the ``server_fqdn`` variable. The username is ``prom`` and the password is in the ``server_password`` variable.

The monitoring service allows you to query the present and historical data. You can see historical data in a basic graphing UI. You can also see current alarms.

To access the alerting service, go to the URL in the ``alertmanager_fqdn`` variable. The username is ``prom`` and the password is in the ``alertmanager_password`` variable.

The alerting service handles actually sending alarms. Alarms are raised to relevant ODS staff and OCP staff.

In the alerting service you can also put in a temporary "silence", with definitions of what alarms will be silenced. This can be used to avoid alerts if you know you are about to do something that would generate an alarm, such as taking a server off-line.

To add a new server to Prometheus:

-  Make sure ``prometheus-client-apache`` or ``prometheus-client-nginx`` is included for the server in ``salt/top.sls``.
-  Deploy to the server you want to monitor.
-  For Apache, Salt will try to work out a domain name to use for the client server automatically. It might fail to do this, if the server is not aware of it's own domain name (Bytemark servers tend to be fine, Hetzner tend not to). Check the host name in ``/etc/apache2/sites-enabled/prometheus-client.conf``. If it gets this wrong, you can set one manually by setting the ``prometheus.client_fqdn`` variable (You can also change the ``prometheus.client_port`` variable). Make sure you set these variables for one server only, and not all servers! Deploy again.
-  For Nginx, it will by default serve the documents on a different port, as defined in ``salt/nginx/prometheus-client`` (currently 9158).
-  Test this by going to the endpoint in a web browser. You should know the URL from the steps above. The username is ``prom`` and the password is in the ``prometheus.client_password`` variable. Click ``Metrics`` and you should see a text response, listing variables and values.
-  Now update ``salt/private/prometheus-server-monitor/conf-prometheus.yml`` and add details of the new endpoint.
-  Deploy to the Prometheus server. While you do so, watch the Status / Targets page in the monitoring service and make sure the server can access the new endpoint without problems.


.. _hosting:

Hosting
-------

OCP uses:

-  `Linode <https://cloud.linode.com/>`__ for the `Helpdesk CRM <https://crm.open-contracting.org>`__, managed by `Dogsbody Technology <https://www.dogsbody.com>`__

   -  Contact: sysadmin@dogsbody.com

-  `Hetzner <https://robot.your-server.de/server>`__ for Kingfisher, managed by Open Data Services

   -  Contact: code@opendataservices.coop
   -  The 'opencontractingpartnership' and 'opencontracting-dogsbody' users have full access. The 'opencontracting' user has limited access.

-  `Bytemark <https://panel.bytemark.co.uk/servers>`__ for all others, managed by Open Data Services

   -  Contact: code@opendataservices.coop
   -  The 'opendataservices' user has secondary access to the 'opencontracting' account.

-  GitHub Pages for the `Extension Explorer <https://extensions.open-contracting.org/>`__

.. toctree::
   :caption: Service-specific information
   :maxdepth: 3

   docs.rst

Communicating during downtime
-----------------------------

For services managed by Open Data Services, please see the `protocol <https://docs.google.com/document/d/1qAoh2scU5ZMGC_WYFjjNNJU-34NzYaC4V2xjmb2G75k/edit>`__ for planned and unplanned downtime.
