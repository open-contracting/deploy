Configure certificates
======================

Create a private key and self-signed certificate
------------------------------------------------

#. Create a ``server.conf`` configuration file, setting ``subjectAltName`` as appropriate, for example:

   .. code-block:: ini

      [req]
      prompt = no
      x509_extensions = v3_ca
      distinguished_name = req_distinguished_name

      [req_distinguished_name]
      C = US
      ST = DC
      L = Washington
      O = Open Contracting Partnership
      CN = open-contracting.org
      emailAddress = sysadmin@open-contracting.org

      [v3_ca]
      subjectAltName = DNS:xyz.open-contracting.org

#. Create a private key and self-signed certificate.

   .. code-block:: bash

      openssl req -nodes -x509 -days 3650 -out server.crt -newkey rsa:2048 -keyout server.key -config server.conf

#. Check the certificate.

   .. code-block:: bash

      openssl x509 -in server.crt -noout -text

Reference:

-  `openssl-req man page <https://www.openssl.org/docs/manmaster/man1/openssl-req.html>`__
-  `openssl-x509 man page <https://www.openssl.org/docs/manmaster/man1/openssl-x509.html>`__
