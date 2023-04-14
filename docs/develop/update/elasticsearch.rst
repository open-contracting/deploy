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

Enable ReadOnlyREST
-------------------

As stated by Elasticsearch, `"Do not expose Elasticsearch directly to users." <https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting-security.html>`__ For the OCDS documentation, we use the `ReadOnlyREST <https://readonlyrest.com>`__ plugin to control access.

.. note::

   Instead of configuring SSL certificates in Elasticsearch, we proxy traffic through Apache.

#. Add the ``elasticsearch.plugins.readonlyrest`` state file to your service's target in the ``salt/top.sls`` file.

#. Set ``elasticsearch.version`` and ``elasticsearch.plugins.readonlyrest`` in your service's Pillar file, for example:

.. code-block:: yaml

   elasticsearch:
     version: 8.6.2
     plugins:
       readonlyrest:
         version: 1.47.0_es8.6.2

#. :doc:`Deploy the service<../../deploy/deploy>`

#. Add users for public searches and for admin actions. Add to your service's *private* Pillar file, replacing ``AUTH_KEY_SHA512`` with the output of ``echo -n 'USERNAME:PASSWORD' | shasum -a 512`` (replacing ``USERNAME`` and ``PASSWORD`` with a strong password each time):

   .. code-block:: yaml
      :emphasize-lines: 4-10

      elasticsearch:
        plugins:
          readonlyrest:
            users:
              - auth_key_sha512: AUTH_KEY_SHA512
                username: public
                groups:
                  - public
              - auth_key_sha512: AUTH_KEY_SHA512
                username: manage
                groups:
                  - manage

#. Test the public user, replacing ``PASSWORD``. For example, for the ``standard.open-contracting.org`` domain:

   .. code-block:: bash

      curl -u 'public:PASSWORD' https://standard.open-contracting.org/search/ocdsindex_en/_search \
      -H 'Content-Type: application/json' \
      -d '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

#. Test the admin user, replacing ``PASSWORD``. For example, for the ``standard.open-contracting.org`` domain:

   .. code-block:: bash
      curl -u 'manage:PASSWORD' https://standard.open-contracting.org/search/_cat/indices

Troubleshoot
~~~~~~~~~~~~

If a request gets a HTTP 4XX error, connect to the server, and run:

.. code-block:: bash

   tail -f /var/log/elasticsearch/elasticsearch.log

You will see a message like (newlines are added for readability):

.. code-block:: none
   :emphasize-lines: 2,6,9,10,13,14,15,17,19-30

   [2020-12-23T23:26:01,367][INFO ][t.b.r.a.l.AccessControlLoggingDecorator] [live.docs.opencontracting.uk0.bigv.io]
     FORBIDDEN by default req={
       ID:2016835989-238874394#2554,
       TYP:GetIndexRequest,
       CGR:N/A,
       USR:manage (attempted),
       BRS:true,
       KDX:null,
       ACT:indices:admin/get,
       OA:174.89.151.140/32,
       XFF:null,
       DA:5.28.62.151/32,
       IDX:ocdsindex_en,
       MET:HEAD,
       PTH:/ocdsindex_en,
       CNT:<N/A>,
       HDR:Accept=*/*, Authorization=<OMITTED>, Host=standard.open-contracting.org, User-Agent=curl/7.64.1, content-length=0,
       HIS:
         [Allow localhost->
           RULES:[hosts->false],
           RESOLVED:[indices=ocdsindex_en]
         ],
         [Allow the public group to search indices created by OCDS Index->
           RULES:[groups->false],
           RESOLVED:[indices=ocdsindex_en]
         ],
         [Allow the manage group to manage indices created by OCDS Index->
           RULES:[groups->true, actions->false],
           RESOLVED:[user=manage;group=manage;av_groups=manage;indices=ocdsindex_en]
         ]
     }

The relevant content is:

-  ``FORBIDDEN by default`` means no access control (ACL) block matched the request.
-  ``USR:`` indicates the user to be matched by `users <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#users>`__ or `groups <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#groups>`__ rules.
-  ``ACT:`` indicates the Elasticsearch action to be matched by `actions <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#actions>`__ rules.
-  ``OA:`` indicates the origin address to be matched by `hosts <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#hosts>`__ rules.
-  ``IDX:`` indicates the Elasticsearch index to be matched by `indices <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#indices>`__ rules.
-  ``MET:`` indicates the HTTP method, ``PTH:`` the URL path, and ``HDR:`` the HTTP headers. Check that ``Authorization`` is set.

   .. note::

      While rules at the HTTP level are allowed, "please refrain from using HTTP level rules," as `documented by ReadOnlyREST <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#methods>`__.

-  ``HIS:`` indicates which rules passed (``true``) or failed (``false``), and how values were resolved. This is the most relevant information for debugging ACL blocks.
