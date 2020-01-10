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

Salt does not (yet) setup a Prometheus server to collect metrics from these servers. Currently, Open Data Services runs a Prometheus server to process client data, which raises alarms to ODS staff only (`#31 <https://github.com/open-contracting/deploy/issues/31>`__).

.. _hosting:

Hosting
-------

OCP uses:

-  `Linode <https://cloud.linode.com/>`__ for the `Helpdesk CRM <https://crm.open-contracting.org>`__, managed by `Dogsbody Technology <https://www.dogsbody.com>`__

   -  Contact: sysadmin@dogsbody.com

-  `Hetzner <https://robot.your-server.de/server>`__ for Kingfisher, managed by Open Data Services

   -  Contact: code@opendataservices.coop

-  `Bytemark <https://panel.bytemark.co.uk/servers>`__ for all others, managed by Open Data Services

   -  Contact: code@opendataservices.coop

-  GitHub Pages for the `Extension Explorer <https://extensions.open-contracting.org/>`__

.. toctree::
   :caption: Host-specific information
   :maxdepth: 3

   hetzner.rst
   bytemark.rst

Communicating during downtime
-----------------------------

For services managed by Open Data Services, please see the `protocol <https://docs.google.com/document/d/1qAoh2scU5ZMGC_WYFjjNNJU-34NzYaC4V2xjmb2G75k/edit>`__ for planned and unplanned downtime.
