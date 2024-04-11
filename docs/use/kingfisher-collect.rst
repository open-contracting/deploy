Kingfisher Collect
==================

Read the `Kingfisher Collect <https://kingfisher-collect.readthedocs.io/en/latest/>`__ documentation, which covers general usage.

.. note::

   Is the service unresponsive or erroring? :doc:`Follow these instructions<index>`.

.. note::

   The ``collect`` user owns the deployment of Kingfisher Collect. Only automated scripts and system administrators should manually delete any data and log files.

Review a new publication
------------------------

#. `Create an issue <https://github.com/open-contracting/kingfisher-collect/issues/new/choose>`__ to request a new spider in the `kingfisher-collect <https://github.com/open-contracting/kingfisher-collect/issues>`__ repository.
#. :ref:`Schedule a crawl<collect-data>`, once the spider is written and :ref:`deployed<update-spiders>`.
#. :ref:`Wait for the crawl to finish<access-scrapyd-web-service>`.
#. :ref:`Review the crawl's log file<kingfisher-collect-review-log-files>`.
#. Review the data.

.. _access-scrapyd-web-service:

Access Scrapyd's web interface
------------------------------

.. admonition:: One-time setup

   Request a username and password from James or Yohanna. (They will add a key-value pair under the ``apache.sites.kingfisher-collect.htpasswd`` key in the ``pillar/private/kingfisher_main.sls`` file.)

Open https://collect.kingfisher.open-contracting.org to view the statuses and logs of crawls.

.. _collect-data:

Collect data with Kingfisher Collect
------------------------------------

.. admonition:: One-time setup

   :ref:`Create a ~/.netrc file<netrc>`, using the same credentials as :ref:`access-scrapyd-web-service`.

First, `read this section <https://kingfisher-collect.readthedocs.io/en/latest/scrapyd.html#collect-data>`__ of the Kingfisher Collect documentation.

To schedule a crawl, replace ``spider_name`` with a spider's name and ``NAME`` with your name (you can edit the note any way you like), and run, **from your computer**:

.. code-block:: shell-session

   $ curl -n https://collect.kingfisher.open-contracting.org/schedule.json -d project=kingfisher -d spider=spider_name -d note="Started by NAME."
   {"node_name": "ocp04", "status": "ok", "jobid": "6487ec79947edab326d6db28a2d86511e8247444"}

Kingfisher Collect, by default, instructs Kingfisher Process to only create compiled releases. If you need something different:

- Also perform structural checks (slow), by adding ``-d steps=check,compile`` to the command
- Only perform structural checks (slow), by adding ``-d steps=check`` to the command
- Skip both, by adding ``-d steps=`` to the command

To cancel a crawl, replace ``JOBID`` with the job ID from the response or from Scrapyd's `jobs page <https://collect.kingfisher.open-contracting.org/jobs>`__:

.. code-block:: shell-session

   $ curl -n https://collect.kingfisher.open-contracting.org/cancel.json -d project=kingfisher -d job=JOBID
   {"node_name": "ocp04", "status": "ok", "prevstate": "running"}

The crawl won't stop immediately. You can force an unclean shutdown by sending the request again; however, it's preferred to allow the crawl to stop gracefully, so that the log file is completed.

.. _update-spiders:

Update spiders in Kingfisher Collect
------------------------------------

.. admonition:: One-time setup

   :ref:`Create a ~/.netrc file<netrc>`, using the same credentials as :ref:`access-scrapyd-web-service`. Then, `create a ~/.config/scrapy.cfg file <https://kingfisher-collect.readthedocs.io/en/latest/scrapyd.html#configure-kingfisher-collect>`__, and set the ``url`` variable to ``https://collect.kingfisher.open-contracting.org/``.

#. Change to your local directory containing your local repository.
#. Ensure your local repository and the `GitHub repository <https://github.com/open-contracting/kingfisher-collect>`__ are in sync:

   .. code-block:: bash

      git checkout main
      git remote update
      git status

   The output should be exactly:

   .. code-block:: none

      On branch main
      Your branch is up to date with 'origin/main'.

      nothing to commit, working tree clean

#. Activate a virtual environment in which ``scrapyd-client`` is installed, and deploy the spiders:

   .. code-block:: bash

         scrapyd-deploy kingfisher

.. _kingfisher-collect-review-log-files:

Access Scrapy's crawl logs
--------------------------

.. seealso::

   `How to interpret a Scrapy crawl log <https://kingfisher-collect.readthedocs.io/en/latest/logs.html>`__

If using a browser, either:

-  Click on a "Log" link from Scrapyd's `jobs page <https://collect.kingfisher.open-contracting.org/jobs>`__.
-  Open the `logs page for the kingfisher project <https://collect.kingfisher.open-contracting.org/logs/kingfisher/>`__.

If using the command-line:

#. :ref:`Connect to the data support server<connect-kingfisher-server>`.
#. Change to the ``logs`` directory for the ``kingfisher`` project:

   .. code-block:: bash

      cd ~collect/scrapyd/logs/kingfisher

Scrapy statistics are extracted from the end of each log file every hour on the hour, into a new file ending in ``.log.stats`` in the same directory as the log file. Access as above, or, from the `jobs page <https://collect.kingfisher.open-contracting.org/jobs>`__:

-  Right-click on a "Log" link.
-  Select "Copy Link" or similar.
-  Paste the URL into the address bar.
-  Change ``.log`` at the end of the URL to ``.log.stats`` and press Enter.

If you can't wait for the statistics to be extracted, you can connect to the server, replace ``spider_name/alpha-numeric-string``, and run:

.. code-block:: bash

   tac /home/collect/scrapyd/logs/kingfisher/spider_name/alpha-numeric-string.log | grep -B99 statscollectors | tac

If you are frequently running the above, `create an issue <https://github.com/open-contracting/deploy/issues>`__ to change the schedule.

.. tip::

   The log file is named after the job's ID, like ``7df53218f37a11eb80dd0c9d92c523cb.log``. If a crawl no longer appears on the jobs page, it can be difficult to find the crawl's log file, because its filename is opaque. To address this, Kingfisher Collect writes the job's ID to a ``scrapyd-job.txt`` file in the crawl's directory. So, the log file will be at, for example:

   .. code-block:: bash

      cd ~collect/scrapyd
      less logs/kingfisher/colombia/$(cat data/colombia/20210708_212020/scrapyd-log.txt).log

Data retention policy
---------------------

On the first day of each month, the following are deleted:

-  Crawl logs older than 90 days
-  Crawl directories containing exclusively files older than 90 days
