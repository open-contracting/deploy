Pelican
=======

Pelican is composed of:

-  `Pelican backend <https://pelican-backend.readthedocs.io/en/latest/>`__, which extracts compiled releases from Kingfisher Process and measures quality
-  `Pelican frontend <https://pelican-frontend.readthedocs.io/en/latest/>`__, which reports results

Measure a collection
--------------------

.. admonition:: One-time setup

   :ref:`Create a ~/.netrc file<netrc>` for the ``pelican.open-contracting.org`` service, using the same credentials as :ref:`access-scrapyd-web-service`.

To create a report, submit a POST request to the ``/api/datasets/`` endpoint. Set ``name`` to the spider's name and the collection date (a.k.a. data version) for easy reference, and set ``collection_id`` to the **compiled** collection ID. For example:

.. code-block:: bash

   curl -n --json '{"name":"spider_name_2020-01-01","collection_id":123}' https://pelican.open-contracting.org/api/datasets/

After a few seconds, you should see your report being processed at https://pelican.open-contracting.org.

.. note::

   Pelican is more robust to structural errors in OCDS data than it was in 2021. That said, it could fail (stall) on structural errors. If so, :ref:`sentry` will notify James and Yohanna.

.. seealso::

   `Pelican frontend's web API documentation <https://pelican.open-contracting.org/api/schema/swagger-ui/>`__

Measure time-based checks
~~~~~~~~~~~~~~~~~~~~~~~~~

If a report exists for an old collection, and Kingfisher Process has a new collection of the same dataset, you can create a report for that new collection that calculates time-based checks between the two collections. Set ``ancestor_id`` to the ID of the previous report in Pelican:

.. code-block:: bash

   curl -n --json '{"name":"spider_name_2021-02-03","collection_id":456,"ancestor_id":1}' https://pelican.open-contracting.org/api/datasets/

Check on progress
-----------------

https://pelican.open-contracting.org indicates the status of reports. In general, this is sufficient. However, you can use the RabbitMQ management interface to check that work isn't stuck, :ref:`like for Kingfisher Process<kingfisher-process-rabbitmq>`, instead reading the ``pelican_backend_`` rows.

Read and export a report
------------------------

Open https://pelican.open-contracting.org. Your username and password are the same as for :ref:`Kingfisher Collect<access-scrapyd-web-service>`.

Pelican signs you in as that username. OCP team members see every report. Anyone else sees nothing until a publisher is configured for them in the `administration site <https://pelican.open-contracting.org/admin/>`__, and then sees only the reports named ``{spider}_{date}`` for that publisher's spider.

To add a user, add a key-value pair under the ``apache.sites.pelican_frontend.htpasswd`` key in the ``pillar/private/kingfisher_main.sls`` file, and then configure their publisher (see `Pelican frontend's documentation <https://pelican-frontend.readthedocs.io/en/latest/access.html>`__).

To `export a report <https://pelican-frontend.readthedocs.io/en/latest/export.html>`__, click the report's document icon on the homepage, and fill in the short form.

-  Main template ID: ``1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM`` to use `this template <https://docs.google.com/document/d/1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM/edit>`__. To use another template, share it with pelican@pelican-289615.iam.gserviceaccount.com as a Viewer.
-  Export folder ID: ``1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3`` to use `this folder <https://drive.google.com/drive/folders/1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3>`__. To use another folder, share it with pelican@pelican-289615.iam.gserviceaccount.com as a Contributor.

Download all failed OCIDs
-------------------------

The report displays a sample of the compiled releases that failed a check. To get them all, request the check's ``failures/`` endpoint, which returns one OCID per line.

For a field-level check, use the field's path, and set the ``type`` query string parameter to ``coverage`` or ``quality`` (the default):

.. code-block:: bash

   curl -n -OJ 'https://pelican.open-contracting.org/api/datasets/1/field_level/tender.procuringEntity.name/failures/?type=coverage'

For a compiled release-level check, use the check's name:

.. code-block:: bash

   curl -n -OJ https://pelican.open-contracting.org/api/datasets/1/compiled_release_level/coherent.dates/failures/

.. note:: ``-OJ`` saves the response under the filename that Pelican sets.

Delete a report
---------------

Once you no longer need a report, remember to delete it, replacing ``1`` with its ID:

.. code-block:: bash

   curl -n -X DELETE https://pelican.open-contracting.org/api/datasets/1/
