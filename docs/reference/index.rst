Reference
=========

This section of the documentation describes facts about our servers and deployments.

Monitoring
----------

Servers are monitored by `Prometheus <https://prometheus.io/>`__.

Salt is used to configure Prometheus monitoring on each server. It does not (yet) setup a Prometheus server to collect metrics from these servers.

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
