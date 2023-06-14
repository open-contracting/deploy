OCDS documentation tasks
========================

Clean draft documentation
-------------------------

#. :doc:`SSH<../use/ssh>` into ``standard.open-contracting.org`` as the ``ocds-docs`` user.
#. Run ``1-size.sh`` to get the total sizes of old drafts. For example, for drafts older than 180 days:

   .. code-block:: bash

      ./1-size.sh 180

#. Run ``2-delete.sh`` to delete the old drafts. For example, for drafts older than 180 days:

   .. code-block:: bash

      ./2-delete.sh 180

Check 404 errors
----------------

#. :doc:`SSH<../use/ssh>` into ``standard.open-contracting.org`` as the ``root`` user.
#. Count 404 errors:

   .. code-block:: bash

      zgrep " 404 " /var/log/apache2/other_vhosts_access.log* | cut -d ' ' -f 8 | sort | uniq -c | sort -n
