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

.. _authenticated-origin-pulls:

Accept web traffic from Cloudflare, only
----------------------------------------

Most web traffic is :ref:`proxied through Cloudflare<proxy-status>`, but origin servers accept HTTPS connections from anywhere. Requests that skip Cloudflare are typically vulnerability scans: for ``/.env`` files, for example.

With `Authenticated Origin Pulls <https://developers.cloudflare.com/ssl/origin-configuration/authenticated-origin-pull/>`__, Cloudflare presents a client certificate when it connects to the origin server, and Apache rejects any connection without it during the TLS handshake.

#. Check which requests skip Cloudflare. Such a request has the same visitor address (``%a``) and peer address (``%{c}a``), whereas a proxied request has a Cloudflare address as its peer:

   .. code-block:: bash

      # Requests that matched a ServerName. Read the */access.log files, instead, if site logs are split.
      awk '$2 == $(NF-1)' /var/log/apache2/other_vhosts_access.log
      # Requests that matched no ServerName, which are typically vulnerability scans.
      awk '$1 == $(NF-1)' /var/log/apache2/access.log

#. Check that every hostname served by the server is :ref:`proxied<proxy-status>` in Cloudflare. Any other hostname becomes unreachable over HTTPS.
#. :ref:`Enable Authenticated Origin Pulls<cloudflare-origin-pulls>` in Cloudflare, if not already enabled. Origin servers ignore the client certificate until they are configured to require it.
#. Add to the server's Pillar file:

   .. code-block:: yaml
      :emphasize-lines: 3

      apache:
        public_access: True
        proxied: True

#. :doc:`Deploy the server<../../deploy/deploy>`
#. Check that the sites are reachable through Cloudflare, and unreachable directly, replacing ``SERVERNAME`` and ``ORIGIN_IP``:

   .. code-block:: bash

      curl -sS -o /dev/null -w '%{http_code}\n' https://SERVERNAME/
      curl -sS -o /dev/null --resolve SERVERNAME:443:ORIGIN_IP https://SERVERNAME/

   The first command should report ``200``. The second should fail the TLS handshake, reporting an alert about a certificate that is required but not sent.

Port 80 stays open, and serves only the redirect to HTTPS and the challenges that Let's Encrypt reads, so :ref:`certificates are acquired<ssl-certificates>` as before.

.. attention::

   The setting applies to all of the server's sites at once, and a mistake affects them all at once.

   The server's own hostname (like ``ocp99.open-contracting.org``) is never proxied, as that would `break SSH access <https://blog.cloudflare.com/cloudflare-now-supporting-more-ports/>`__. Its placeholder website is therefore unreachable over HTTPS. Its certificate is still renewed, and :doc:`port knocking<../../use/ssh>` is unaffected.

.. note::

   Uptime checks that connect to an origin server over HTTPS, instead of to Cloudflare, fail. Configure them to use the hostname, as visitors do.

   Nginx is not supported, as it serves one site, only.

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

Split site logs
---------------

Add to your server's Pillar file:

.. code-block:: yaml

   apache:
     site_logs: True

This will configure sites to use their own log file in ``/var/log/apache2/{site}/access.log``.

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
