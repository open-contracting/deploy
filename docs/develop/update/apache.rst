Configure Apache
================

.. seealso::

   `GoAccess to visualize Apache logs offline <https://goaccess.io>`__. For example:

   .. code-block:: bash

      goaccess other_vhosts_access.log -o report.html --log-format=VCOMBINED --date-spec=hr

.. _allow-http:

Allow HTTP/HTTPS traffic
------------------------

Add to your server's Pillar file:

.. code-block:: yaml

   apache:
     public_access: True

This will:

-  Open ports 80 (HTTP) and 443 (HTTPS)
-  Install the Apache service
-  Enable the :ref:`mod_http2, mod_md and mod_ssl<apache-modules>` Apache modules
-  Enable an Apache configuration for acquiring Let's Encrypt certificates

If you are only using Apache to serve Python apps, continue from :doc:`python`.

Bind addresses
--------------

If the server has multiple web servers for different IPs, add to your server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 2-3

   apache:
     ipv4: 65.21.93.181
     ipv6: 2a01:4f9:3b:45ca::2
     wait_for_networking: True

.. _apache-sites:

Add sites
---------

Add to your server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 3-9

   apache:
     public_access: True
     sites:
       ocds-docs-live:
         configuration: docs
         servername: standard.open-contracting.org
         serveraliases: ['myalias.open-contracting.org']
         context:
           mykey: myvalue

This will:

-  Create a ``/etc/apache2/sites-available/ocds-docs-live.conf`` file that includes a ``/etc/apache2/sites-available/ocds-docs-live.conf.include`` file, which, together, will:

   -  If ``apache.public_access`` is ``True`` and ``https`` isn't ``False``:

      -  :ref:`ssl-certificates`
      -  Create a virtual host serving port 443
      -  Configure a HTTP to HTTPS permanent redirect
      -  Add a ``Strict-Transport-Security`` header

   -  Create a virtual host serving port 80
   -  Set the virtual host's ``servername`` and ``serveraliases``, if any

-  Symlink the new file from the ``/etc/apache2/sites-enabled`` directory
-  Reload the Apache service if the configuration changed

The example above uses the `docs <https://github.com/open-contracting/deploy/blob/main/salt/apache/files/sites/docs.conf.include>`__ configuration. The keys of the ``context`` mapping are made available as variables in the configuration template.

.. note::

   To delete a virtual host, :ref:`follow these instructions<delete-apache-virtual-host>`.

Reference: `What to use When <https://httpd.apache.org/docs/2.4/sections.html#whichwhen>`__

Add basic authentication
~~~~~~~~~~~~~~~~~~~~~~~~

#. Add, in a private Pillar file:

   .. code-block:: yaml

      apache:
        sites:
          SITE:
            htpasswd:
              NAME: PASSWORD

   This will add the user to the ``/etc/apache2/.htpasswd-SITE`` file.

#. Reference the htpasswd file from an Apache configuration file. For example:

   .. code-block:: apache

      <Location "/">
          AuthName "My Site"
          AuthType Basic
          AuthUserFile /etc/apache2/.htpasswd-SITE
          Require valid-user
      </Location>

#. Or, use the `proxy <https://github.com/open-contracting/deploy/blob/main/salt/apache/files/sites/proxy.conf.include>`__ configuration in your server's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 5,7-10

   apache:
     public_access: True
     sites:
       kingfisher-collect:
         configuration: proxy
         servername: collect.data.open-contracting.org
         context:
           documentroot: /home/collect/scrapyd
           proxypass: http://localhost:6800/
           authname: Kingfisher Scrapyd

.. note::

   To delete an htpasswd entry, :ref:`follow these instructions<delete-htpasswd-entry>`.

.. _ssl-certificates:

Acquire SSL certificates
------------------------

If ``apache.public_access`` is ``True`` and ``https`` isn't ``False``, `mod_md <https://httpd.apache.org/docs/2.4/mod/mod_md.html>`__ is used to acquire SSL certificates from Let's Encrypt. If the server name is new, you must:

#. :ref:`Add a CNAME record<update-external-services>`.

   .. attention::

      Let's Encrypt will reach a `Failed Validation <https://letsencrypt.org/docs/failed-validation-limit/>`__ limit if DNS is not propagated.

      In the meantime, you can :ref:`use Let's Encrypt's staging environment<mod_md-test>`.

#. :doc:`Deploy the server<../../deploy/deploy>`, if not already done. ``mod_md`` will request a certificate from Let's Encrypt.
#. Check for a message in ``/var/log/apache2/error.log``, replacing ``TARGET``:

   .. code-block:: bash

      ./run.py TARGET cmd.run 'grep "Managed Domain" /var/log/apache2/error.log'

   For example:

   .. code-block:: none

      AH10059: The Managed Domain ssl-test.open-contracting.org has been setup and changes will be activated on next (graceful) server restart.

#. Reload the Apache service, replacing ``TARGET``:

   .. code-block:: bash

      ./run.py TARGET service.reload apache2

The service should now be available at its ``https://`` web address.

.. tip::

   In case of error, see `mod_md's troubleshooting guide <https://github.com/icing/mod_md#how-to-fix-problems>`__.

   If you need to test the acquisition of certificates, :ref:`use Let's Encrypt's staging environment<mod_md-test>`.

.. card:: Test SSL configuration

   You can test the SSL configuration using `SSL Labs <https://www.ssllabs.com/ssltest/>`__.

   Test the HTTP redirect, replacing ``SERVERNAME``:

   .. code-block:: shell-session
      :emphasize-lines: 2,5

      $ curl -I http://SERVERNAME
      HTTP/1.1 301 Moved Permanently
      Date: Fri, 11 Dec 2020 12:34:56 GMT
      Server: Apache/2.4.46 (Ubuntu)
      Location: https://SERVERNAME/
      Content-Type: text/html; charset=iso-8859-1

   Test the HTTPS response:

   .. code-block:: shell-session
      :emphasize-lines: 2,5

      $ curl -IL https://SERVERNAME
      HTTP/2 200
      date: Fri, 11 Dec 2020 04:26:57 GMT
      server: Apache/2.4.46 (Ubuntu)
      strict-transport-security: max-age=15768000

   Check the certificates' status:

   .. code-block:: bash

      curl https://SERVERNAME/.httpd/certificate-status

.. _apache-modules:

Enable Apache modules
---------------------

You might need to enable Apache modules to use non-core directives in your configuration files.

There are state files for common modules:

apache.modules.headers
  Provides `Header and RequestHeader directives <https://httpd.apache.org/docs/2.4/mod/mod_headers.html>`__.
apache.modules.http2
  Provides support for the `HTTP/2 protocol <https://httpd.apache.org/docs/2.4/mod/mod_http2.html>`__.
apache.modules.md
  Acquires `SSL certificates from Let's Encrypt <https://httpd.apache.org/docs/2.4/mod/mod_md.html>`__.
apache.modules.passenger
  Adds the `Passenger app server <https://www.phusionpassenger.com/>`__.
apache.modules.proxy
  Adds `ProxyPass, ProxyPreserveHost and other directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy.html>`__. Included by ``apache.modules.proxy_http``.
apache.modules.proxy_fcgi
  Provides supports for the `FastCGI protocol in ProxyPass directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy_fcgi.html>`__. Included by the ``php-fpm`` state file.
apache.modules.proxy_http
  Provides support for `HTTP/HTTPS requests in ProxyPass directives <https://httpd.apache.org/docs/2.4/en/mod/mod_proxy_http.html>`__. Included by the ``python_apps`` state file.
apache.modules.rewrite
  Adds the `mod_rewrite rule-based rewriting engine to rewrite requested URLs on the fly <https://httpd.apache.org/docs/2.4/mod/mod_rewrite.html>`__.
apache.modules.ssl
  Included and required by ``apache.modules.md``.

To enable a module, include the relevant state file in your service's state file. For example:

.. code-block:: yaml

   include:
     - apache.modules.headers

To disable an Apache module, :ref:`follow these instructions<delete-apache-module>`.

If you need another module, consider adding a state file under the ``salt/apache/modules`` directory.

.. note::

   The following state files are not used presently:

   -  apache.modules.deflate
   -  apache.modules.expires
   -  apache.modules.remoteip

Configure Apache modules
------------------------

autoindex
~~~~~~~~~

`mod_autoindex <https://httpd.apache.org/docs/2.4/mod/mod_autoindex.html>`__ is disabled by default. To enable it:

.. code-block:: yaml
   :emphasize-lines: 2-4

   apache:
     modules:
       mod_autoindex:
         enabled: True

.. _mod_md-configure:

md
~~

You can configure `mod_md <https://httpd.apache.org/docs/2.4/mod/mod_md.html>`__ by adding Apache directives to your server's Pillar file. For example:

.. code-block:: yaml
   :emphasize-lines: 3-5

   apache:
     public_access: True
     modules:
       mod_md:
         MDMessageCmd: /opt/postgresql-certificates.sh

.. _mod_md-test:

To test a configuration, use Let's Encrypt's `staging environment <https://letsencrypt.org/docs/staging-environment/>`__ to avoid the `duplicate certificate limit <https://letsencrypt.org/docs/duplicate-certificate-limit/>`__:

.. code-block:: yaml
   :emphasize-lines: 6

   apache:
     public_access: True
     modules:
       mod_md:
         MDMessageCmd: /opt/postgresql-certificates.sh
         MDCertificateAuthority: https://acme-staging-v02.api.letsencrypt.org/directory

You can then remove the ``/etc/apache2/md/staging/DOMAIN`` and ``/etc/apache2/md/domains/DOMAIN`` directories as often as needed, and :ref:`re-acquire certificates<ssl-certificates>`.

.. tip::

   If you use the ``MDMessageCmd`` or ``MDNotifyCmd`` directives, add ``LogLevel: md:debug`` during testing, and check the Apache error log for lines containing ``cmd(``:

   .. code-block:: bash

      tail -f /var/log/apache2/error.log
