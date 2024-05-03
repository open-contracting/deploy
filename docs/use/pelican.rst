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

   `Pelican frontend's web API documentation <https://pelican.open-contracting.org/api/swagger-ui/>`__

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

To `export a report <https://pelican-frontend.readthedocs.io/en/latest/export.html>`__, click the report's document icon on the homepage, and fill in the short form.

-  Main template ID: ``1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM`` to use `this template <https://docs.google.com/document/d/1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM/edit>`__. To use another template, share it with data-tools@open-contracting.org.
-  Export folder ID: ``1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3`` to use `this folder <https://drive.google.com/drive/folders/1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3>`__. To use another folder, share it with data-tools@open-contracting.org.

Delete a report
---------------

Once you no longer need a report, remember to delete it, replacing ``1`` with its ID:

.. code-block:: bash

   curl -n -X DELETE https://pelican.open-contracting.org/api/datasets/1/
