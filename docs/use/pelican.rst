Pelican
=======

Pelican is composed of a backend that `extracts OCDS data and measures its quality <https://pelican-backend.readthedocs.io/en/latest/>`__ and a frontend that `reports the results <https://pelican-frontend.readthedocs.io/en/latest/>`__.

Measure a collection
--------------------

Pelican backend provides an `add command <https://pelican-backend.readthedocs.io/en/latest/tasks/datasets.html>`__ to measure a compiled release collection in Kingfisher Process.

#. :ref:`Connect to the data support server<connect-kingfisher-server>`
#. Change to the ``pelican-backend`` directory:

   .. code-block:: bash

      cd /data/deploy/pelican-backend

#. Name the report using the spider's name and the collection date for easy reference, and provide the collection ID for the compiled releases:

   .. code-block:: bash

      docker compose run --rm cron python manage.py add spider_name_2020-01-01 123

.. attention::

   Pelican is more robust to structural errors in OCDS data than it was in 2021. That said, it might still fail on structural errors. If so, :ref:`sentry` is expected to notify James and Yohanna.

Read and export a report
------------------------

Open https://pelican.open-contracting.org. Your username and password are the same as for :ref:`Kingfisher Collect<access-scrapyd-web-service>`.

To `export a report <https://pelican-frontend.readthedocs.io/en/latest/export.html>`__, click the report's document icon on the homepage, and fill in the short form.

-  Main template ID: ``1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM`` to use `this template <https://docs.google.com/document/d/1jSGZKNJP6wBVPwi3JsvdkZ9FSpUwrK2SJxZoQQuJdnM/edit>`__. To use another template, share it with data-tools@open-contracting.org.
-  Export folder ID: ``1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3`` to use `this folder <https://drive.google.com/drive/folders/1ZVwf9cr29E4uCuWaVRiQLJI7_ejE00h3>`__. To use another folder, share it with data-tools@open-contracting.org.

Check on progress
-----------------

https://pelican.open-contracting.org indicates the status of reports. In general, this is sufficient. However, you can use the RabbitMQ management interface to check that work isn't stuck, :ref:`like for Kingfisher Process<kingfisher-process-rabbitmq>`, instead reading the ``pelican_backend_`` rows.
