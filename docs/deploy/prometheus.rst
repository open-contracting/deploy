Prometheus tasks
================

Add a server
------------

Make sure ``prometheus-client-apache`` or ``prometheus-client-nginx`` is included for the server in ``salt/top.sls``.

Deploy to the server you want to monitor.

For Apache, Salt will try to work out a domain name to use for the client server automatically. It might fail to do this, if the server is not aware of it's own domain name (Bytemark servers tend to be fine, Hetzner tend not to). Check the host name in ``/etc/apache2/sites-enabled/prometheus-client.conf``. If it gets this wrong, you can set one manually by setting the ``prometheus.client_fqdn`` variable (You can also change the ``prometheus.client_port`` variable). Make sure you set these variables for one server only, and not all servers! Deploy again.

For Nginx, it will by default serve the documents on a different port, as defined in ``salt/nginx/prometheus-client`` (currently 9158).

Test this by going to the endpoint in a web browser. You should know the URL from the steps above. The username is ``prom`` and the password is in the ``prometheus.client_password`` variable. Click ``Metrics`` and you should see a text response, listing variables and values.

Now update ``salt/private/prometheus-server-monitor/conf-prometheus.yml`` and add details of the new endpoint.

Deploy to the Prometheus server. While you do so, watch the Status / Targets page in the monitoring service and make sure the server can access the new endpoint without problems.

