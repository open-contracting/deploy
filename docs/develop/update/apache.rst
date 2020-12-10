Configure Apache
================

.. _allow-http:

Allow HTTP/HTTPS traffic
------------------------

Add to your service's Pillar file:

.. code-block:: yaml

   apache:
     public_access: true

This will open ports 80 (HTTP) and 443 (HTTPS), as long as either an :ref:`apache.sites key<apache-sites>` is set (next section), or the :doc:`python_apps state file<python>` is included.

If you are only using Apache to serve Python apps, continue from :doc:`python`.

.. _apache-sites:

Add sites
---------

Add to your service's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 3,4,5,6,7,8,9

   apache:
     public_access: true
     sites:
       ocds-docs-live:
         configuration: docs
         servername: standard.open-contracting.org
         serveraliases: ['live.standard.open-contracting.org']
         https: force
         context:
           testing: false
           ocds_cove_backend: https://cove.live3.cove.opencontracting.uk0.bigv.io
           oc4ids_cove_backend: https://cove-live.oc4ids.opencontracting.uk0.bigv.io
           timeout: 1830  # 30 sec longer than cove's uwsgi.harakiri

This will:

-  Install the Apache service
-  Create a ``/etc/apache2/sites-available/{site}.conf`` file that includes a ``/etc/apache2/sites-available/{site}.conf.include`` file, which, together:

   -  Listen on port 80
   -  Listen on port 443, if ``https`` is ``force``
   -  Create a virtual host
   -  Set the ``servername`` and ``serveraliases``, if any
   -  Set up an HTTP/HTTPS redirect, if ``https`` is ``force``
   -  Set up an `HTTP-01 challenge <https://letsencrypt.org/docs/challenge-types/>`__, if ``https`` is ``certonly``

-  Symlink the new files from the ``etc/apache2/sites-enabled`` directory
-  Acquire SSL certificates if ``https`` is ``force`` or ``certonly``
-  Restart the Apache service if the configuration changed

The example above uses the `docs <https://github.com/open-contracting/deploy/blob/master/salt/apache/files/config/docs.conf.include>`__ configuration. The keys of the ``context`` mapping are made available as variables in the configuration template.

.. _ssl-certificates:

Acquire SSL certificates
------------------------

.. note::

   This section is pending the `switch to certbot <https://github.com/open-contracting/deploy/issues/66>`__.

.. _apache-modules:

Enable Apache modules
---------------------

You might need to enable Apache modules to use non-core directives in your configuration files.

There are state files for common modules:

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

To enable a module, include the relevant state file in your service's state file. For example:

.. code-block:: yaml

   include:
     - apache.modules.remoteip

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
