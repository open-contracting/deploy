Create a server
===============

A server is created either when a service is moving to a new server, or when a service is being introduced.

#. Create the server via the hosting provider's interface
#. Add or update the service's DNS entries in `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Add the server to Prometheus

If the service is moving to a new server:

#. Replace all occurrences of the old server's FQDN and IP address in this repository

If the service is being introduced:

#. Add its configuration to this repository
#. Add its downtime monitor to `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Add its error monitor to `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__

Finally:

#. :doc:`Deploy the service<deploy>`

Additional steps to be added via `this issue <https://github.com/open-contracting/deploy/issues/16>`__.
