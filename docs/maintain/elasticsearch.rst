Maintain Elasticsearch
======================

Troubleshoot
------------

Check the log files in the ``/var/log/elasticsearch`` directory, including:

-  ``elasticsearch_deprecation.log``
-  ``elasticsearch_deprecation.json``

Errors are logged in ``/var/log/elasticsearch/elasticsearch.log``, for example:

-  "All shards failed for phase: [query]", often followed by:

   -  Failed to parse query [*query*]
   -  Cannot parse '*query*'
   -  Failed to execute [SearchRequest{ … "query":"*query*" … }]

Delete documents
----------------

List indices:

.. code-block:: bash

   curl https://standard.open-contracting.org:9200/_cat/indices

Expire documents using `OCDS Index <https://github.com/open-contracting/ocds-index>`__:

.. code-block:: bash

   ocdsindex expire https://standard.open-contracting.org:9200 --exclude-file=ocdsindex-exclude.txt

Explore indices
---------------

List base URLs in a given index:

.. code-block:: bash

   curl -X GET -H "Content-Type: application/json" "localhost:9200/ocdsindex_en/_search?size=0&pretty" \
   -d '{"aggs": {"base_urls": {"terms": {"field": "base_url", "size": 1000}}}}' 

Delete documents matching a base URL:

.. code-block:: bash

   curl -X POST -H 'Content-Type: application/json' "localhost:9200/ocdsindex_en/_delete_by_query" \
   -d '{"query": {"term": {"base_url": "https://standard.open-contracting.org/dev/"}}}'

Explore queries
---------------

.. code-block:: bash

   zgrep -Eoh "q=[^&]+&" /var/log/apache2/* | grep -v '=test&' | grep -v '=tender&' | sort
