DNS
===

DNS is hosted with `GoDaddy <https://sso.godaddy.com>`__.

Lock all domain names in the `Domain Portfolio <https://dcc.godaddy.com/control/portfolio>`__.

TTL standardisation
-------------------

The Time to Live (TTL) of a DNS record indicates how long DNS clients should cache the DNS record. Set the TTL as follows:

.. list-table::
   :header-rows: 1

   * - Purpose
     - Record type
     - TTL
   * - Hostname
     - A and AAAA
     - 1 day (86400 seconds)
   * - High availability service
     - CNAME
     - 5 min (300 seconds)
   * - Other
     - CNAME
     - 1 hour (3600 seconds)
