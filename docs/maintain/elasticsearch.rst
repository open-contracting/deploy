Maintain Elasticsearch
======================

Troubleshoot
------------

Check the ``/var/log/elasticsearch/elasticsearch.log`` and ``/var/log/elasticsearch/elasticsearch_server.json`` log files for non-INFO messages:

.. code-block:: bash

   grep -v INFO /var/log/elasticsearch/elasticsearch.log /var/log/elasticsearch/elasticsearch_server.json

Check the log files in the ``/var/log/elasticsearch`` directory, including:

-  ``elasticsearch_deprecation.log``
-  ``elasticsearch_deprecation.json``

Errors are logged in ``/var/log/elasticsearch/elasticsearch.log``, for example:

-  "All shards failed for phase: [query]", often followed by:

   -  Failed to parse query [*query*]
   -  Cannot parse '*query*'
   -  Failed to execute [SearchRequest{ … "query":"*query*" … }]

.. note::

   ``/etc/elasticsearch/log4j2.properties`` configures a log file rotation strategy of:

   .. code-block:: none

      appender.rolling.strategy.action.condition.nested_condition.type = IfAccumulatedFileSize
      appender.rolling.strategy.action.condition.nested_condition.exceeds = 2GB

   To change to a `7-day rotation strategy <https://www.elastic.co/guide/en/elasticsearch/reference/current/logging.html>`__, update this repository to replace this with:

   .. code-block:: none

      appender.rolling.strategy.action.condition.nested_condition.type = IfLastModified
      appender.rolling.strategy.action.condition.nested_condition.age = 7D

Manage data
-----------

.. admonition:: One-time setup

   Set the password of the ``manage`` user of the ``standard.open-contracting.org`` service in a :ref:`~/.netrc file<netrc>`.

List indices:

.. code-block:: bash

   curl -n https://standard.open-contracting.org/search/_cat/indices

List base URLs in a given index, for example:

.. code-block:: bash

   curl -n -X GET 'https://standard.open-contracting.org/search/ocdsindex_en/_search?size=0&pretty' \
   --json '{"aggs": {"base_urls": {"terms": {"field": "base_url", "size": 10000}}}}'

Delete documents matching a base URL:

.. code-block:: bash

   curl -n -X POST 'https://standard.open-contracting.org/search/ocdsindex_en/_delete_by_query' \
   --json '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

Expire documents using `OCDS Index <https://github.com/open-contracting/ocds-index>`__ (``pip install ocdsindex``):

.. code-block:: bash

   ocdsindex expire https://standard.open-contracting.org:443/search/ --exclude-file=ocdsindex-exclude.txt

Search documents in a given index matching a base URL, for example:

.. code-block:: bash

   curl -n -X GET 'https://standard.open-contracting.org/search/ocdsindex_en/_search?size=10000' \
   --json '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

List users' queries:

.. code-block:: bash

   zgrep -Eoh "q=[^&]+&" /var/log/apache2/* | grep -v '=test&' | grep -v '=tender&' | sort

Upgrade
-------

.. note::

   Before upgrading Elasticsearch, check that all plugins (below) support the new version.

.. note::

   `OCDS Index <https://ocds-index.readthedocs.io/en/latest/>`__ supports Elasticsearch 7.x only.

#. :doc:`Connect to the server<../use/ssh>` as the ``root`` user.
#. Perform any outstanding updates:

   .. code-block:: bash

      apt-get update && apt-get dist-upgrade

#. Update Elasticsearch (the Elasticsearch package is held to prevent accidental updates):

   .. code-block:: bash

      apt-mark unhold elasticsearch
      apt-get update && apt-get dist-upgrade
      apt-mark hold elasticsearch

#. Update plugins, as described below.
#. Test Elasticsearch is working.

   #. Check that the service is running without errors.

      .. code-block:: bash

         systemctl status elasticsearch

   #. Test the `site search works <https://standard.open-contracting.org/latest/en/search/?q=example&check_keywords=yes&area=default>`__.

ReadOnlyREST
^^^^^^^^^^^^

If the `ReadOnlyREST plugin <https://readonlyrest.com>`__ is used:

#. Check the `changelog <https://github.com/beshu-tech/readonlyrest-docs/blob/master/changelog.md>`__ for a new version of ReadOnlyREST. Note which versions of Elasticsearch are supported.
#. In the server's Pillar file, set ``elasticsearch.plugins.readonlyrest.version`` to the version of ReadOnlyREST to install, and set ``elasticsearch.version`` to the already installed version of Elasticsearch:

   .. code-block:: bash

      dpkg-query --show elasticsearch

#. Stop Elasticsearch, for example:

   .. code-block:: bash

      systemctl stop elasticsearch

#. Uninstall ReadOnlyREST, for example:

   .. code-block:: bash

      /usr/share/elasticsearch/bin/elasticsearch-plugin remove readonlyrest

#. :doc:`Deploy the server<../deploy/deploy>`

Reference: `Upgrading the plugin <https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md#upgrading-the-plugin>`__
