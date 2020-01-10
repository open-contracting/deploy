Delete a server
===============

A server is deleted either when a service is moving to a new server, or when a service is being retired.

#. If appropriate, notify relevant users of the change
#. Shutdown the server via the hosting provider's interface
#. Update or remove the service's DNS entries from `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Replace or remove all occurrences of the server's FQDN and IP address from this repository
#. Remove the server from Prometheus

If the service is being retired:

#. Remove its configuration from this repository
#. Remove its downtime monitor from `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Remove its error monitor from `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__

Finally:

#. Cancel the server via the hosting provider's interface
