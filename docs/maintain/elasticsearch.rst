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

   To change to a `7-day rotation strategy <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/logging.html>`__, update this repository to replace this with:

   .. code-block:: none

      appender.rolling.strategy.action.condition.nested_condition.type = IfLastModified
      appender.rolling.strategy.action.condition.nested_condition.age = 7D

Manage data
-----------

List indices:

.. code-block:: bash

   curl -u 'manage:PASSWORD' https://standard.open-contracting.org:9200/_cat/indices

List base URLs in a given index, for example:

.. code-block:: bash

   curl -X GET -u 'public:PASSWORD' 'https://standard.open-contracting.org:9200/ocdsindex_en/_search?size=0&pretty' \
   -H 'Content-Type: application/json' \
   -d '{"aggs": {"base_urls": {"terms": {"field": "base_url", "size": 10000}}}}'

Delete documents matching a base URL:

.. code-block:: bash

   curl -X POST -u 'manage:PASSWORD' 'https://standard.open-contracting.org:9200/ocdsindex_en/_delete_by_query' \
   -H 'Content-Type: application/json' \
   -d '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

Expire documents using `OCDS Index <https://github.com/open-contracting/ocds-index>`__:

.. code-block:: bash

   ocdsindex expire https://manage:PASSWORD@standard.open-contracting.org:9200 --exclude-file=ocdsindex-exclude.txt

Search documents in a given index matching a base URL, for example:

.. code-block:: bash

   curl -X GET -u 'public:PASSWORD' 'https://standard.open-contracting.org:9200/ocdsindex_en/_search?size=10000' \
   -H 'Content-Type: application/json' \
   -d '{"query": {"term": {"base_url": "https://standard.open-contracting.org/staging/1.1-dev/"}}}'

List users' queries:

.. code-block:: bash

   zgrep -Eoh "q=[^&]+&" /var/log/apache2/* | grep -v '=test&' | grep -v '=tender&' | sort
