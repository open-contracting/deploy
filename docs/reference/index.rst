Reference
=========

Communicating during downtime
-----------------------------

For services managed by Open Data Services, please see the `protocol <https://docs.google.com/document/d/1qAoh2scU5ZMGC_WYFjjNNJU-34NzYaC4V2xjmb2G75k/edit>`__ for planned and unplanned downtime.

Monitoring
----------

Prometheus
~~~~~~~~~~

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Salt is used to configure Prometheus monitoring on each server, and to set up a Prometheus server to to collect metrics from these servers.

We use the following exporters:

-  `Node Exporter <https://github.com/prometheus/node_exporter>`__ is installed on each server to export hardware and OS metrics like disk space used, memory used, etc.

Read the :doc:`user guide <../use/prometheus>` to learn how to use Prometheus.

DMARC Analyzer
~~~~~~~~~~~~~~

OCP's `DMARC policy <https://support.google.com/a/answer/2466563>`__ (``dig TXT _dmarc.open-contracting.org``) sends aggregate and forensic reports to `DMARC Analyzer <https://app.dmarcanalyzer.com/>`__.

Sentry
~~~~~~

Application errors are reported to `Sentry <https://sentry.io/>`__, which notifies individual email addresses. Not all services report errors to Sentry.

UptimeRobot
~~~~~~~~~~~

Website downtime is monitored by `UptimeRobot <https://uptimerobot.com/>`__, which notifies sysadmin email addresses at OCP and ODS. Keyword monitors are used where possible.

.. _hosting:

Hosting
-------

OCP uses:

-  `Linode <https://cloud.linode.com/>`__ for the `Helpdesk CRM <https://crm.open-contracting.org>`__, managed by `Dogsbody Technology <https://www.dogsbody.com>`__

   -  Contact: sysadmin@dogsbody.com
   -  `Network status <https://status.linode.com/>`__: We subscribe to only: Regions: EU-West (London), Backups: EU-West (London) Backups.
   -  Access: The 'opencontractingpartnership' and 'opencontracting-dogsbody' users have full access. The 'opencontracting' user has limited access.
   -  Backups: It is configured to have one daily backup and two weekly backups. Dogsbody also configured daily and weekly backups to `Google Cloud Platform <https://ocds-standard-development-handbook.readthedocs.io/en/latest/systems/services.html#cloud-platform>`__.

-  `Hetzner <https://robot.your-server.de/server>`__ for Kingfisher, managed by Open Data Services

   -  Contact: code@opendataservices.coop
   -  `Network status <https://www.hetzner-status.de/en.html>`__

-  `Bytemark <https://panel.bytemark.co.uk/servers>`__ for all others, managed by Open Data Services

   -  Contact: code@opendataservices.coop
   -  `Network status <https://status.bytemark.org/>`__
   -  Access: The 'opendataservices' user has secondary access to the 'opencontracting' account.
   -  Backups: It is configured to have one weekly backup (see :doc:`../deploy/create_server`).

-  GitHub Pages for the `Extension Explorer <https://extensions.open-contracting.org/>`__

   -  `Network status <https://www.githubstatus.com>`__

.. toctree::
   :caption: Service-specific information

   docs.rst
