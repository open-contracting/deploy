Configure Apache
================

Acquire SSL certificates
------------------------

.. note::

   This section is pending the `switch to certbot <https://github.com/open-contracting/deploy/issues/66>`__.

Enable Apache modules
---------------------

There are state files for common modules, which you can include in your service's state file. For example:

.. code-block:: yaml

   include:
      - apache.modules.remoteip

The state files are:

apache.modules.proxy
  Adds `ProxyPass, ProxyPreserveHost and other directives <https://httpd.apache.org/docs/current/en/mod/mod_proxy.html>`__. Included by ``apache.modules.proxy_http`` and ``apache.modules.proxy_uwsgi``.
apache.modules.proxy_http
  Provides support for `HTTP/HTTPS requests in ProxyPass directives <https://httpd.apache.org/docs/current/en/mod/mod_proxy_http.html>`__. Included by the ``python_apps`` state file.
apache.modules.proxy_uwsgi
  Provides supports for the `uWSGI protocol in ProxyPass directives <https://httpd.apache.org/docs/current/en/mod/mod_proxy_uwsgi.html>`__. Included by the ``python_apps`` state file.
apache.modules.remoteip
  Adds `RemoteIPHeader, RemoteIPTrustedProxy and other directives <https://httpd.apache.org/docs/current/en/mod/mod_remoteip.html>`__.
apache.modules.ssl
  Adds `SSL directives <https://httpd.apache.org/docs/current/mod/mod_ssl.html>`__. Included by the ``apache.letsencrypt`` state file, which is included by the ``apache.public`` state file, which is included by the ``python_apps`` state file.

If you need another module, consider adding a state file under the ``salt/apache/modules`` directory.

Add basic authentication
------------------------

#. Create an htpasswd file in a user's home directory, by adding the following data to a Pillar file:

   .. code-block:: yaml

      apache:
        htpasswd:
          SYSTEM-USER:
            name: NAME
            password: PASSWORD

   For example:

   .. code-block:: yaml

      apache:
        htpasswd:
          prometheus-server:
            name: prom
            password: secret

#. Reference the htpasswd file from an Apache configuration file. For example:

   .. code-block:: apache

      <Location "/">
          ProxyPass http://localhost:6789/

          AuthName "Open Contracting Partnership Prometheus Monitor"
          AuthType Basic
          AuthUserFile /home/prometheus-server/htpasswd
          Require valid-user
      </Location>
