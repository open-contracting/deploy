Troubleshoot
============

jinja2.exceptions.TemplateNotFound
----------------------------------

If you ``{% include %}`` a file, this error might be raised. To resolve the issue, add the included file to the ``extra_filerefs`` list in the ``Saltfile`` file (`Salt issue <https://github.com/saltstack/salt/issues/21370>`__).

Alternatively, instead of including shared content in a service-specific file, rewrite the configuration so that the shared content is the template file, and the service-specific content is Pillar data.

Jinja caching issues
--------------------

`Imported <https://docs.saltproject.io/en/latest/topics/jinja/index.html#include-and-import>`__ files are sometimes cached. To check whether this is the case, delete the imported file (e.g. ``lib.sls``) and run the Salt function. If there is no change, the file is cached. To clear the cache:

.. code-block:: bash

   rm -rf /var/tmp/.*_salt
