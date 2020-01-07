Delete a server
===============

#. Replace or remove all occurrences of the server's FQDN and IP address in this repository
#. Update or remove the DNS entries for the service from `GoDaddy <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__
#. Update or remove the service's downtime monitor from `UptimeRobot <https://uptimerobot.com/dashboard>`__
#. Update or remove the service's error monitor from `Sentry <https://sentry.io/organizations/open-data-services/projects/>`__
#. Remove the server from Prometheus
#. Shutdown the server via the hosting provider's interface
#. If appropriate, notify relevant users of the change
#. Cancel the server via the hosting provider's interface
