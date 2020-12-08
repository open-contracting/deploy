OCDS Documentation
==================

This page serves as an orientation to how different components of the OCDS documentation relate to each other.

Servers
-------

The ``docs`` target serves OCDS documentation (e.g. `1.1 <https://standard.open-contracting.org/1.1/>`__), its profiles (e.g. `Public Private Partnerships <https://standard.open-contracting.org/profiles/ppp/latest/en/>`__) draft documentation (below). It is a reverse proxy to the `OCDS Data Review Tool <https://standard.open-contracting.org/review/>`__ and the `OC4IDS Data Review Tool <https://standard.open-contracting.org/infrastructure/review/>`__. It also serves Elasticsearch.

Version and language switchers
------------------------------

The version switcher links to a ``/switcher`` URL path with a ``branch`` URL parameter. The language switcher links to a ``/{version}/switcher`` URL path with a ``lang`` URL parameter. These are redirected by Apache (you can search for ``/switcher`` in its config files).

Search API
----------

The `search.js file <https://github.com/open-contracting/standard_theme/blob/open_contracting/standard_theme/static/js/search.js>`__ in the ``standard_theme`` repository sends an unauthenticated request to the API's ``/search`` endpoint to retrieve search results.

The `documentation deploy script <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ in this repository sends an authenticated request to the API's ``/index_ocds`` endpoint to index the documentation for the OCDS and its profiles.

Continuous deployment
---------------------

The repositories for OCDS documentation use continuous integration to push builds to staging directory on the server and to rebuild the search index for the documentation:

-  Each branch of the `standard <https://github.com/open-contracting/standard>`__ repository is automatically built to:

   .. code-block:: none

      https://standard.open-contracting.org/staging/{branch}/en/

-  Each branch of a profile’s repository is automatically built to:

   .. code-block:: none

      https://standard.open-contracting.org/staging/profiles/{root}/{branch}/en/

In detail, continuous integration runs `deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ in this repository. For this script to succeed, continuous integration must be :ref:`configured<publish-draft-documentation>` to have access to the server and to the Search API's ``/index_ocds`` endpoint.
