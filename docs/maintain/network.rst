Network tasks
=============

Troubleshoot DNS
----------------

Trace a DNS query, starting from the root servers:

.. code-block:: bash

   dig +trace contrataciones.gov.py

Attempt a DNS query, starting from a nameserver:

.. code-block:: bash

   host contrataciones.gov.py 1.1.1.1
