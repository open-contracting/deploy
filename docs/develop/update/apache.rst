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
   -  Listen on port 443, if ``apache.public_access`` is ``true`` and ``https`` is ``force``
   -  Create a virtual host
   -  Set the ``servername`` and ``serveraliases``, if any
   -  Set up an HTTP/HTTPS redirect, if ``apache.public_access`` is ``true`` and ``https`` is ``force``

-  Symlink the new files from the ``etc/apache2/sites-enabled`` directory
-  Restart the Apache service if the configuration changed

The example above uses the `docs <https://github.com/open-contracting/deploy/blob/master/salt/apache/files/sites/docs.conf.include>`__ configuration. The keys of the ``context`` mapping are made available as variables in the configuration template.

.. _ssl-certificates:

Acquire SSL certificates
------------------------

If ``apache.public_access`` is ``true`` and ``https`` is ``force``, `mod_md <https://httpd.apache.org/docs/2.4/mod/mod_md.html>`__ is used to acquire SSL certificates from Let's Encrypt. If the server name is new, you must:

-  :doc:`Deploy the service<deploy>` with the new server name, if not done already.
-  ``mod_md`` will request a certificate from Let's Encrypt.
-  Wait for a message in ``/var/log/apache2/error.log``, replacing ``TARGET``:

   .. code-block:: bash

      ./run.py TARGET cmd.run 'grep "Managed Domain" /var/log/apache2/error.log'

   For example:

   .. code-block:: none

      AH10059: The Managed Domain ssl-test.open-contracting.org has been setup and changes will be activated on next (graceful) server restart.

-  Reload the Apache service, replacing ``TARGET``:

   .. code-block:: bash

      ./run.py TARGET service.reload apache2

The service should now be available at its ``https://`` web address.

At any time, you can check the status of the certificates, replacing ``SERVERNAME``:

.. code-block:: bash

   curl http://SERVERNAME/.httpd/certificate-status

In case of error, see `mod_md's troubleshooting guide <https://github.com/icing/mod_md#how-to-fix-problems>`__. If you need to test the acquisition of certificates, `use Let's Encrypt's staging environment <https://github.com/icing/mod_md#dipping-the-toe>`__. ``mod_md`` also offers several `monitoring options <https://github.com/icing/mod_md#monitoring>`__.

You can test the SSL configuration using `SSL Labs <https://www.ssllabs.com/ssltest/>`__.

.. _apache-modules:

Enable Apache modules
---------------------

You might need to enable Apache modules to use non-core directives in your configuration files.

There are state files for common modules:

apache.modules.md
  Acquires `SSL certificates from Let's Encrypt <https://httpd.apache.org/docs/2.4/mod/mod_md.html>`__.
apache.modules.proxy
  Adds `ProxyPass, ProxyPreserveHost and other directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy.html>`__. Included by ``apache.modules.proxy_http`` and ``apache.modules.proxy_uwsgi``.
apache.modules.proxy_http
  Provides support for `HTTP/HTTPS requests in ProxyPass directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy_http.html>`__. Included by the ``python_apps`` state file.
apache.modules.proxy_uwsgi
  Provides supports for the `uWSGI protocol in ProxyPass directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy_uwsgi.html>`__. Included by the ``python_apps`` state file.
apache.modules.remoteip
  Adds `RemoteIPHeader, RemoteIPTrustedProxy and other directives <https://httpd.apache.org/docs/2.4/en/mod/mod_remoteip.html>`__.
apache.modules.ssl
  Included and required by ``apache.modules.md``.
apache.modules.watchdog
  Included and required by ``apache.modules.md``.

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
