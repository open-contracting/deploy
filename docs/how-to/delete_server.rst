Delete a server
===============

A server is deleted either when a service is moving to a new server (:doc:`create the new server<create_server>`, first), or when a service is being retired.

#. If appropriate, notify relevant users of the change
#. Remove the server from Prometheus
#. Shutdown the server via the :ref:`host<hosting>`'s interface
#. Remove all occurrences of the server's FQDN and IP address from this repository

If the service is being retired:

#. Remove its configuration from this repository
#. Remove its DNS entries from `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Remove its downtime monitor from `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Remove its error monitor from `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__

Finally:

#. Cancel the server via the host's interface
