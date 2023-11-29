Configure Nginx
===============

.. warning::

   :doc:`Use Apache<apache>`. Nginx is only used for `bi.dream.gov.ua <https://bi.dream.gov.ua>`__.

Allow HTTP/HTTPS traffic
------------------------

Add to your service's Pillar file:

.. code-block:: yaml

   nginx:
     public_access: True

This will:

-  Open ports 80 (HTTP) and 443 (HTTPS)
-  Install the Nginx service
-  Install and configure the `Certbot <https://certbot.eff.org>`__ tool for acquiring Let's Encrypt certificates

Add sites
---------

Prepare domain validation
~~~~~~~~~~~~~~~~~~~~~~~~~

Add to your service's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 3-7

   apache:
     public_access: True
     sites:
       mysite:
         configuration: acme
         servername: myname.open-contracting.org
         serveraliases: ['myalias.open-contracting.org']

This will:

-  Create a ``/etc/nginx/sites-available/mysite.conf`` file, which will:

   -  Create a virtual host serving port 80
   -  Set the virtual host's ``servername`` and ``serveraliases``, if any

-  Symlink the new file from the ``etc/nginx/sites-enabled`` directory
-  Reload the Nginx service if the configuration changed

Acquire SSL certificates
~~~~~~~~~~~~~~~~~~~~~~~~

If the server name is new, you must:

#. :ref:`Add a CNAME record<update-external-services>`.

   .. warning::

      Let's Encrypt will reach a `Failed Validation <https://letsencrypt.org/docs/failed-validation-limit/>`__ limit if DNS is not propagated.

#. :doc:`Deploy the service<../../deploy/deploy>`, if not already done.
#. :doc:`Connect to the server<../../use/ssh>`
#. Acquire SSL certificates, replacing ``DOMAIN``:

   .. code-block::

      certbot --nginx -d DOMAIN

The service should now be available at its ``https://`` web address. Certbot will auto-renew the certificates.

.. tip::

   If you need to test the acquisition of certificates, `use Let's Encrypt's staging environment <https://github.com/icing/mod_md#dipping-the-toe>`__.

Configure site
~~~~~~~~~~~~~~

You can now use your own configuration, instead of ``acme``:

.. code-block:: yaml
   :emphasize-lines: 5,8-9

   apache:
     public_access: True
     sites:
       mysite:
         configuration: myconfig
         servername: myname.open-contracting.org
         serveraliases: ['myalias.open-contracting.org']
         context:
           mykey: myvalue

The keys of the ``context`` mapping are made available as variables in the configuration template.

Adapt the `basic <https://github.com/open-contracting/deploy/blob/main/salt/nginx/files/sites/basic.conf>`__ configuration, which will:

-  Create a virtual host serving port 443
-  Configure a HTTP to HTTPS permanent redirect
-  Add a ``Strict-Transport-Security`` header
-  Configure `OCSP Stapling <https://en.wikipedia.org/wiki/OCSP_stapling>`__
