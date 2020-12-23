Configure Elasticsearch
=======================

Check system configuration
--------------------------

Elasticsearch has instructions under `Important System Configuration <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/system-config.html>`__, most of which don't require any changes.

-  Check `file descriptors <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/file-descriptors.html>`__:

   .. code-block:: bash

      ulimit -n

-  Check `virtual memory <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/vm-max-map-count.html>`__:

   .. code-block:: bash

      sysctl vm.max_map_count

-  Check `number of threads <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/max-number-of-threads.html>`__:

   .. code-block:: bash

      ulimit -u

-  Check `JNA temporary directory isn't mounted with noexec <https://www.elastic.co/guide/en/elasticsearch/reference/7.10/executable-jna-tmpdir.html>`__:

   .. code-block:: bash

      grep tmp /etc/fstab
