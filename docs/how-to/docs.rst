OCDS Documentation
==================

.. _publish-draft-documentation:

Publish draft documentation
---------------------------

To configure an OCDS profile to push builds to the :ref:`ocds-documentation` staging server:

#. Access the repository’s Travis page
#. Click "More options" and "Settings"
#. Set the private key:

   #. Enter "PRIVATE_KEY" in the first input under "Environment Variables"
   #. Get the ``ocds-docs`` user’s private key (`deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ will restore the newlines and spaces):

      .. code-block:: bash

         cat salt/private/ocds-docs/ssh_authorized_keys_from_travis_private | tr '\n' '#' | tr ' ' '_'

   #. Enter the private key in the second input
   #. Click "Add"

#. Set the search secret:

   #. Enter "SEARCH_SECRET" in the first input under "Environment Variables"
   #. Get the value of the ``ocds_secret`` key in ``pillar/private/standard_search_pillar.sls``
   #. Enter it in the second input
   #. Click "Add"
