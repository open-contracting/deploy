DNS Configuration
=================

DNS is currently hosted with `GoDaddy <https://sso.godaddy.com>`__

TTL Standardisation
-------------------

When creating new DNS records the Time To Live (TTL) should be set matching the below standards. This value sets how long clients cache the DNS record.

.. list-table::
   :header-rows: 1

   * - Purpose
     - Record Type
     - TTL Value
   * - Server hostname records
     - A and AAAA records
     - 1 day (86400 Seconds)
   * - High Availability Application
     - CNAME
     - 5 min (300 Seconds)
   * - Non-HA Application / All other records
     - CNAME
     - 1 hour (3600 Seconds)
