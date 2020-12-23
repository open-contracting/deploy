Configure Elasticsearch
=======================

Check system configuration
--------------------------

Elasticsearch has instructions under `Important System Configuration <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/system-config.html>`__, most of which don't require any changes. To check if changes are needed:

-  `File descriptors <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/file-descriptors.html>`__:

   .. code-block:: bash

      ulimit -n

-  `Virtual memory <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/vm-max-map-count.html>`__:

   .. code-block:: bash

      sysctl vm.max_map_count

-  `Number of threads <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/max-number-of-threads.html>`__:

   .. code-block:: bash

      ulimit -u

-  `JNA temporary directory isn't mounted with noexec <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/executable-jna-tmpdir.html>`__:

   .. code-block:: bash

      grep tmp /etc/fstab

-  `TCP retransmission timeout <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/system-config-tcpretries.html>`__:

   .. code-block:: bash

      sysctl net.ipv4.tcp_retries2

Set swappiness value
--------------------

`As recommended by Elasticsearch <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/setup-configuration-memory.html#swappiness>`__, add to your service's Pillar file:

.. code-block:: yaml

   vm:
     swappiness: 1

Enable public access
--------------------

As stated by Elasticsearch, `"Do not expose Elasticsearch directly to users." <https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting-security.html>`__ For the OCDS documentation, we use the `ReadOnlyREST <https://readonlyrest.com>`__ plugin to control access.

ReadOnlyREST is open source, but only available via web form. We store its ZIP file in the `deploy-salt-private <https://github.com/open-contracting/deploy-salt-private>`__ repository. ReadOnlyREST's ZIP file should match the installed Elasticsearch version.

.. note::

   This setup assumes that :doc:`Apache<apache>` and Elasticsearch serve content from the same domain, and can share an SSL certificate.

#. Add the ``elasticsearch.plugins.readonlyrest`` state file to your service's target in the ``salt/top.sls`` file.

#. Create a personal access token with the "repo" scope for a `machine user <https://docs.github.com/en/free-pro-team@latest/developers/overview/managing-deploy-keys#machine-users>`__ on GitHub. The machine user must have read-only access to the deploy-salt-private repository.

#. Allow Salt to access the ReadOnlyREST ZIP file. Add to your service's *private* Pillar file, replacing ``ACCESS_TOKEN``:

   .. code-block:: yaml

      github:
        access_token: ACCESS_TOKEN

#. Allow anyone to access Elasticsearch. Add to your service's Pillar file:

   .. code-block:: yaml

      elasticsearch:
        public_access: True

#. Allow cross-origin HTTP requests (optional). Add to your service's Pillar file, for example:

   .. code-block:: yaml
      :emphasize-lines: 2

      elasticsearch:
        allowed_origins: https://standard.open-contracting.org

#. Configure Apache to create JKS keystores when renewing SSL certificates, so that the ReadOnlyREST plugin can configure SSL using the same certificates:

   .. code-block:: yaml
      :emphasize-lines: 2-4

      apache:
        modules:
          mod_md:
            MDNotifyCmd: /opt/pem-to-keystore.sh

#. Set a JKS keystore password. Add to your service's *private* Pillar file, replacing ``KEY_PASS`` with a `strong password <https://www.lastpass.com/password-generator>`__:

   .. code-block:: yaml
      :emphasize-lines: 2-4

      elasticsearch:
        plugins:
          readonlyrest:
            key_pass: KEY_PASS

#. Add users for public searches and for admin actions. Add to your service's *private* Pillar file, replacing ``AUTH_KEY_SHA512`` with the output of ``echo -n 'public:PASSWORD' | shasum -a 512`` (replacing ``PASSWORD`` with a strong password each time):

   .. code-block:: yaml
      :emphasize-lines: 4-10

      elasticsearch:
        plugins:
          readonlyrest:
            users:
              - auth_key_sha512: AUTH_KEY_SHA512
                username: public
                groups: ["public"]
              - auth_key_sha512: AUTH_KEY_SHA512
                username: manage
                groups: ["manage"]

#. :doc:`Deploy the service<../../deploy/deploy>`

#. Create the JKS keystore. For example, for the ``standard.open-contracting.org`` domain:

   .. code-block:: bash

      ./run.py 'docs' cmd.run '/opt/pem-to-keystore.sh standard.open-contracting.org'

#. Restart the Elasticsearch service:

   .. code-block:: bash

      ./run.py 'docs' service.restart elasticsearch

#. Test the public user, replacing ``PASSWORD``. For example, for the ``standard.open-contracting.org`` domain:

   .. code-block:: bash

      curl -u 'public:PASSWORD' 'https://standard.open-contracting.org:9200/ocdsindex_en/_search' \
      -H 'Content-Type: application/json' \
      -d '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

#. Test the admin user, replacing ``PASSWORD``. For example, for the ``standard.open-contracting.org`` domain:

   .. code-block:: bash

      curl -u 'manage:PASSWORD' https://standard.open-contracting.org:9200/_cat/indices
