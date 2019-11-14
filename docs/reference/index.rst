Reference
=========

This section of the documentation describes facts about our servers and deployments.

Monitoring
----------

UptimeRobot
^^^^^^^^^^^

Website downtime is monitored by `UptimeRobot <https://uptimerobot.com/>`__, which notifies sysadmin email addresses at OCP and ODS. Keyword monitors are used where possible.

Sentry
^^^^^^

Application errors are reported to `Sentry <https://sentry.io/>`__, which notifies individual email addresses. Not all services report errors to Sentry.

Prometheus
^^^^^^^^^^

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Salt is used to configure Prometheus monitoring on each server.

We use the following techniques:

* `Node Exporter <https://github.com/prometheus/node_exporter>`__ is installed on each machine to monitor things like disk space, memory use, etc.
* `Black Box Exporter <https://github.com/prometheus/blackbox_exporter>`__ is used to check websites are up. Keyword checks are more complicated than on UptimeRobot and so are not configured.

It does not (yet) setup a Prometheus server to collect metrics from these servers. Currently an ODS Prometheus server processes data and raises alarms to ODS staff only. This will be changed soon.


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
