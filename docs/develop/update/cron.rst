Configure cron
==============

.. note::

   Most scheduled tasks should be configured in the context of a relevant state file. For tasks that are not specific to a service or application, follow these instructions.

Add a cron job
--------------

Add to the server's Pillar file, for example:

.. code-block:: yaml

   cron:
     incremental:
       do_excluded_supplier.sh:
         identifier: DOMINICAN_REPUBLIC_EXCLUDED_SUPPLIER
         hour: 1
         minute: random

This will:

-  Create a ``bin`` directory in the home directory of the ``incremental`` user
-  Create an executable ``do_excluded_supplier.sh`` file in the ``bin`` directory
-  Schedule the executable file as a cron job for the ``incremental`` user, using the arguments provided

.. tip::

   Use `Cronhub <https://crontab.cronhub.io>`__ to interpret cron schedule expressions.
