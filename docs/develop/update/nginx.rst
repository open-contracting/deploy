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

You can configure a site with the default configuration, or a custom configuration. Either case will end with:

-  Symlink the new file from the ``/etc/nginx/sites-enabled`` directory
-  Reload the Nginx service if the configuration changed

.. note::

   To delete a virtual host, :ref:`follow these instructions<delete-nginx-virtual-host>`.

Default configuration
~~~~~~~~~~~~~~~~~~~~~

Add to your service's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 3-9

   apache:
     public_access: True
     sites:
       mysite:
         include: default
         servername: myname.open-contracting.org
         serveraliases: ['myalias.open-contracting.org']
         context:
           mykey: myvalue

This will:

-  Create a ``/etc/nginx/sites-available/mysite.conf`` file that includes a ``/etc/nginx/sites-available/mysite.conf.include`` file, which, together, will:

   -  Configure TLS certificates
   -  Create virtual hosts serving ports 80 and 443
   -  Set the virtual hosts' ``servername`` and ``serveraliases``, if any
   -  Configure a HTTP to HTTPS permanent redirect
   -  Add a ``Strict-Transport-Security`` header
   -  Configure `OCSP Stapling <https://en.wikipedia.org/wiki/OCSP_stapling>`__

Here, the ``/etc/nginx/sites-available/mysite.conf.include`` file uses the ``salt/nginx/files/sites/default.conf.include`` template with a ``mykey`` variable.

Custom configuration
~~~~~~~~~~~~~~~~~~~~

Instead, add to your service's Pillar file:

.. code-block:: yaml
   :emphasize-lines: 5

   apache:
     public_access: True
     sites:
       mysite:
         configuration: mycustom
         servername: myname.open-contracting.org
         serveraliases: ['myalias.open-contracting.org']
         context:
           mykey: myvalue

This will:

-  Create a ``/etc/nginx/sites-available/mysite.conf`` file

Here, The ``/etc/nginx/sites-available/mysite.conf`` file uses the ``salt/nginx/files/sites/mycustom.conf`` template with ``servername``, ``serveraliases`` and ``mykey`` variables.

Acquire SSL certificates
------------------------

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
