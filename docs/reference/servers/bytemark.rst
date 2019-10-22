Bytemark
========

Bytemark hosts the OCDS documentation (described below) and:

-  ``live.cove.opencontracting.uk0.bigv.io``: `OCDS Data Review Tool <https://standard.open-contracting.org/review/>`__
-  ``cove-live.oc4ids.opencontracting.uk0.bigv.io``: `OC4IDS Data Review Tool <https://standard.open-contracting.org/infrastructure/review/>`__
-  ``live.redash.opencontracting.uk0.bigv.io``: `Redash <http://live.redash.opencontracting.uk0.bigv.io:9090>`__
-  ``live.toucan.opencontracting.uk0.bigv.io``: `Toucan <https://toucan.open-contracting.org>`__

Bytemark, under Open Data Services' account, hosts ``dev.cove.opendataservices.coop`` for the `development version <http://dev.cove.opendataservices.coop/review/>`__ of the OCDS Data Review Tool. This server is also used for other ODS clients.

.. _ocds-documentation:

OCDS documentation
------------------

-  ``live.docs.opencontracting.uk0.bigv.io`` serves `standard.open-contracting.org <https://standard.open-contracting.org/>`__ and is a reverse proxy (gateway) to ``live.cove.opencontracting.uk0.bigv.io`` and ``cove-live.oc4ids.opencontracting.uk0.bigv.io`` (mentioned above) as well as to ``staging.docs.opencontracting.uk0.bigv.io``. It serves released documentation of the OCDS (e.g. `latest <https://standard.open-contracting.org/latest/>`__, `1.0 <https://standard.open-contracting.org/1.0/>`__ and `1.1 <https://standard.open-contracting.org/1.1/>`__) and its profiles (e.g. `Public Private Partnerships <https://standard.open-contracting.org/profiles/ppp/latest/en/>`__).
-  ``staging.docs.opencontracting.uk0.bigv.io`` serves draft documentation of the OCDS and its profiles. If necessary, it can be browsed directly at https://staging.standard.open-contracting.org/.
-  ``live.standard-search.opencontracting.uk0.bigv.io`` serves the Standard Search API, whose base URL is ``http://standard-search.open-contracting.org/v1``.

Version and language switchers
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The version switcher links to a ``/switcher`` URL path with a ``branch`` URL parameter. The language switcher links to a ``/{version}/switcher`` URL path with a ``lang`` URL parameter. These are redirected by Apache (search for ``/switcher`` in its config files). To switch languages, Apache needs to know which versions exist, which are indicated by the Salt variables ``live_versions``, ``profiles`` and ``infrastructure_live_versions``.

Redirects to Extension Explorer
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Extension documentation pages were moved as part of OCDS 1.1.4. The former locations are redirected by Apache (search for ``extensions.open-contracting.org`` in its config files). To do so, Apache needs to know which languages are available, which are indicated by the Salt variables ``langs`` and ``langs_ppp``.

Standard Search API
~~~~~~~~~~~~~~~~~~~

The ```search.js`` file <https://github.com/open-contracting/standard_theme/blob/open_contracting/standard_theme/static/js/search.js>`__ in the ``standard_theme`` repository sends a request to its ``/search`` endpoint to retrieve search results.

The `Travis deploy script <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ in this repository sends a request to its ``/index_ocds`` endpoint to index the documentation for the OCDS and its profiles.

Travis
~~~~~~

Travis has SFTP access to push builds to this server.
