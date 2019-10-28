Bytemark
========

Bytemark hosts the OCDS documentation (described below) and:

-  ``live.cove.opencontracting.uk0.bigv.io`` for the `OCDS Data Review Tool <https://standard.open-contracting.org/review/>`__
-  ``cove-live.oc4ids.opencontracting.uk0.bigv.io`` for the `OC4IDS Data Review Tool <https://standard.open-contracting.org/infrastructure/review/>`__
-  ``live.redash.opencontracting.uk0.bigv.io`` for `Redash <http://live.redash.opencontracting.uk0.bigv.io:9090>`__
-  ``live.toucan.opencontracting.uk0.bigv.io`` for `Toucan <https://toucan.open-contracting.org>`__

Bytemark, under Open Data Services' account, hosts ``dev.cove.opendataservices.coop`` for the `development version <http://dev.cove.opendataservices.coop/review/>`__ of the OCDS Data Review Tool. This server is also used for other ODS clients.

.. _ocds-documentation:

OCDS Documentation
------------------

-  ``live.docs.opencontracting.uk0.bigv.io`` serves released documentation of the OCDS (e.g. `1.1 <https://standard.open-contracting.org/1.1/>`__) and its profiles (e.g. `Public Private Partnerships <https://standard.open-contracting.org/profiles/ppp/latest/en/>`__). It is also a reverse proxy to:

   -  ``live.cove.opencontracting.uk0.bigv.io`` (mentioned above)
   -  ``cove-live.oc4ids.opencontracting.uk0.bigv.io`` (mentioned above)
   -  ``staging.docs.opencontracting.uk0.bigv.io``

-  ``staging.docs.opencontracting.uk0.bigv.io`` serves draft documentation of the OCDS and its profiles. If necessary, it can be `browsed directly <https://staging.standard.open-contracting.org/>`__.
-  ``live.standard-search.opencontracting.uk0.bigv.io`` serves the Search API, whose base URL is http://standard-search.open-contracting.org/v1.

Version and language switchers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The version switcher links to a ``/switcher`` URL path with a ``branch`` URL parameter. The language switcher links to a ``/{version}/switcher`` URL path with a ``lang`` URL parameter. These are redirected by Apache (you can search for ``/switcher`` in its config files).

Search API
~~~~~~~~~~

The `search.js file <https://github.com/open-contracting/standard_theme/blob/open_contracting/standard_theme/static/js/search.js>`__ in the ``standard_theme`` repository sends an unauthenticated request to the API's ``/search`` endpoint to retrieve search results.

The `Travis deploy script <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ in this repository sends an authenticated request to the API's ``/index_ocds`` endpoint to index the documentation for the OCDS and its profiles.

Travis
~~~~~~

The repositories for OCDS documentation use Travis to push builds to the staging server and to rebuild the search index for the documentation:

-  Each branch of the `standard <https://github.com/open-contracting/standard>`__ repository is automatically built to:

   .. code-block:: none

      https://standard.open-contracting.org/{branch}/en/

-  Each branch of a profile’s repository is automatically built to:

   .. code-block:: none

      https://standard.open-contracting.org/profiles/{root}/{branch}/en/

In detail, the repositories use `script deployment <https://docs.travis-ci.com/user/deployment/script/>`__ to run `deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ in this repository. For this script to succeed, Travis must be :ref:`configured<publish-draft-documentation>` to have access to the staging server and to the Search API's ``/index_ocds`` endpoint.
