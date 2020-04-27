Kingfisher Scrape
=================

Read the `Kingfisher Scrape <https://kingfisher-scrape.readthedocs.io/en/latest/>`__ documentation, which cover general usage.

.. _access-scrapyd-web-service:

Access Scrapyd's web interface
------------------------------

.. admonition:: One-time setup

   Save the username (``scrape``) and the password (ask a colleague) in your password manager.

Open http://scrape.kingfisher.open-contracting.org

Collect data with Kingfisher Scrape
-----------------------------------

First, `read this section <https://kingfisher-scrape.readthedocs.io/en/latest/scrapyd.html#collect-data>`__ of the Kingfisher Scrape documentation.

To schedule a crawl, replace ``spider_name`` with a spider's name, ``NAME`` with your name (you can edit the note any way you like), and ``PASSWORD`` with the password for http://scrape.kingfisher.open-contracting.org (ask a colleague), and run:

.. code-block:: bash

   curl http://scrape:PASSWORD@scrape.kingfisher.open-contracting.org/schedule.json -d project=kingfisher -d spider=spider_name -d note="Started by NAME."

To avoid having to replace the password, use a ``.netrc`` file. In order to create (or append the Kingfisher Scrape credentials to) a ``.netrc`` file, replace ``PASSWORD`` with the password, and run:

.. code-block:: bash

   echo 'machine scrape.kingfisher.open-contracting.org login scrape password PASSWORD' >> ~/.netrc

You must change the file's permissions to be readable only by the owner:

.. code-block:: bash

   chmod 600 ~/.netrc

Then, you can run, for example:

.. code-block:: bash

   curl -n http://scrape.kingfisher.open-contracting.org/schedule.json -d project=kingfisher -d spider=spider_name -d note="Started by NAME."

Update spiders in Kingfisher Scrape
-----------------------------------

.. admonition:: One-time setup

   `Create a ~/.config/scrapy.cfg file <https://kingfisher-scrape.readthedocs.io/en/latest/scrapyd.html#configure-kingfisher-scrape>`__, and set the ``url`` variable to ``http://scrape.kingfisher.open-contracting.org/``.

#. Change to your local directory containing your local repository

#. Ensure your local repository and the `GitHub repository <https://github.com/open-contracting/kingfisher-scrape>`__ are in sync:

   .. code-block:: bash

      git checkout master
      git remote update
      git status

   The output should be exactly:

   .. code-block:: none

      On branch master
      Your branch is up to date with 'origin/master'.

      nothing to commit, working tree clean

#. Activate a virtual environment in which ``scrapyd-client`` is installed, and deploy the spiders:

   .. code-block:: bash

         scrapyd-deploy kingfisher

Access Scrapyd's crawl logs
---------------------------

From a browser, click on a "Log" link from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__, or open Scrapyd's `logs page for the kingfisher project <http://scrape.kingfisher.open-contracting.org/logs/kingfisher/>`__.

From the command-line, :ref:`connect to the server<connect-collect-server>`, and change to the ``logs`` directory for the ``kingfisher`` project:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org
   cd scrapyd/logs/kingfisher

Scrapy statistics are extracted from the end of each log file every hour on the hour, into a new file ending in ``.log.stats`` in the same directory as the log file. Access as above, or, from the `jobs page <http://scrape.kingfisher.open-contracting.org/jobs>`__:

-  Right-click on a "Log" link.
-  Select "Copy Link" or similar.
-  Paste the URL into the address bar.
-  Change ``.log`` at the end of the URL to ``.log.stats`` and press Enter.

If you can't wait for the statistics to be extracted, you can connect to the server, replace ``spider_name/alpha-numeric-string``, and run:

.. code-block:: bash

   tac /home/ocdskfs/scrapyd/logs/kingfisher/spider_name/alpha-numeric-string.log | grep -B99 statscollectors | tac

If you are frequently running the above, `create an issue <https://github.com/open-contracting/deploy/issues>`__ to change the schedule.

.. _connect-collect-server:

Connect to the Kingfisher Scrape server
---------------------------------------

.. admonition:: One-time setup

   Ask a colleague to add your SSH key to ``salt/private/authorized_keys/kingfisher_to_add``

Connect to the server as the ``ocdskfs`` user:

.. code-block:: bash

   ssh ocdskfs@scrape.kingfisher.open-contracting.org
