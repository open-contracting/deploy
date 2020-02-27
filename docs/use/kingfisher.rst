Kingfisher
==========

Read the documentation of each component, which cover general usage:

-  `Kingfisher Scrape <https://kingfisher-scrape.readthedocs.io/en/latest/>`__
-  `Kingfisher Process <https://kingfisher-process.readthedocs.io/en/latest/>`__
-  `Kingfisher Views <https://kingfisher-views.readthedocs.io/en/latest/>`__

.. _access-scrapyd-web-service:

Access Scrapyd's web interface
------------------------------

Open http://scrape.kingfisher.open-contracting.org

.. _connect-collect-server:

Connect to the Kingfisher Scrape server
---------------------------------------

Connect to the server as the ``ocdskfs`` user:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org

Collect data with Kingfisher Scrape
-----------------------------------

#. :ref:`Connect to the server<connect-collect-server>`

#. Schedule a crawl and set its note and any other `spider arguments <https://kingfisher-scrape.readthedocs.io/en/latest/use-cases/local.html#collect-data>`__. For example, replace ``spider_name`` with a spider's name and ``NAME`` with your name:

   .. code-block:: bash

      curl http://localhost:6800/schedule.json -d project=kingfisher -d spider=spider_name -d note="Started by NAME."

Update spiders in Kingfisher Scrape
-----------------------------------

#. Merge your changes to the master branch of the `kingfisher-scrape repository <https://github.com/open-contracting/kingfisher-scrape>`__.

#. Connect to the server as the ``ocdskfs`` user and change to the working directory:

   .. code-block:: bash

      ssh ocdskfs@scrape.kingfisher.open-contracting.org
      cd ocdskingfisherscrape

#. Pull your changes into the local repository:

   .. code-block:: bash

      git pull --rebase

#. Activate the virtual environment and Update the project's requirements:

   .. code-block:: bash

      source .ve/bin/activate
      pip install -r requirements.txt

#. Deploy the spiders:

   .. code-block:: bash

         scrapyd-deploy

Access Scrapyd's crawl logs
---------------------------

From a browser, click on a "Log" link from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__, or open Scrapyd's `logs page for the kingfisher project <http://scrape.kingfisher.open-contracting.org/logs/kingfisher/>`__.

From the command-line, connect to the server as the ``ocdskfs`` user, and change to the logs directory for the ``kingfisher`` project:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org
   cd scrapyd/logs/kingfisher

Scrapy statistics are extracted from the end of each log file every hour on the hour, into a new file ending in ``_report.log`` in the same directory as the log file. Access as above, or, from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__:

-  Right-click on a "Log" link.
-  Select "Copy Link" or similar.
-  Paste the URL into the address bar.
-  Change ``.log`` at the end of the URL to ``_report.log`` and press Enter.
