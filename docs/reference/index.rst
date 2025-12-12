Reference
=========

.. toctree::
   :caption: Contents
   :maxdepth: 1

   downtime.rst
   docs.rst
   powerbi.rst

.. seealso::

   `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html#sentry>`__ for access to monitoring and hosting services

Monitoring
----------

.. seealso::

   :ref:`monitor-dmarc-reports`

Ahrefs
~~~~~~

SEO issues are audited by Ahrefs.com's `Site Audit <https://ahrefs.com/site-audit>`__.

Access the `most recent crawl <https://app.ahrefs.com/site-audit/4835895>`__, and:

-  Review *All Issues*, filtering by *Importance*.
-  Review the *Crawl log* for URLs that were *Discarded* due to *Monthly page crawl limit reached*. If there are any:

   -  To review the discarded URLs, click *Uncrawled* from the crawl's *Overview*, and set an *Advanced filter* of *Target no-crawl reason = Monthly page crawl limit reached*.
   -  To exclude URLs from future crawls, click the top-right gear icon, click *Project settings*, click *Crawl settings*, and add one pattern per line to *Don’t crawl URLs matching the pattern*.

      The current patterns are:

      .. code-block:: none

         # OCP's archived corporate website.
         archive\.open-contracting\.org
         # Uploads to an archived website.
         challenge\.open-contracting\.org(/en)?/wp-content/uploads/
         # Page sources for OCDS documentation.
         standard\.open-contracting\.org/\S+\.md\.txt$
         # Sort options on directory listings.
         standard\.open-contracting\.org/\S+\?C=[DMNS];O=[AD]$
         # Default WordPress category pages.
         www\.open-contracting\.org(/(es|ru))?/(audience|author|category|country|events/page|issue|learning-resource-category|open-contracting|region|resource-type|tag)/

Cloudflare Security Insights
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cybersecurity issues are monitored by `Cloudflare <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/home/domains>`__.

Prometheus
~~~~~~~~~~

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Read the :doc:`user guide <../use/prometheus>` to learn how to use Prometheus.

Salt is used to:

-  Install a `Node Exporter <https://github.com/prometheus/node_exporter>`__ service on each server, to export hardware and OS metrics like disk space used, memory used, etc.
-  Set up a Prometheus server to collect metrics from all servers, and to email alerts if metrics are out of bounds

.. _sentry:

Sentry
~~~~~~

Application errors are reported to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__, which notifies individual email addresses. All Salt-managed, OCP-authored services report errors to Sentry.

.. tip::

   From the *All Events* tab of an issue, to filter out frequent events to find infrequent events:

   #. Click the … button in the *TITLE* column
   #. Click the *Exclude from filter* menu item
   #. If needed, replace the end of the title with the wildcard character ``*``

   You can also type a negated key like ``!message:``, and Sentry will display autocomplete options.

.. seealso::

   -  `Sentry search reference <https://docs.sentry.io/concepts/search/>`__

SecurityScorecard
~~~~~~~~~~~~~~~~~

Cybersecurity issues are monitored by `SecurityScorecard <https://platform.securityscorecard.io>`__.

`Patching cadence issues <https://support.securityscorecard.com/hc/en-us/articles/115002965683-Patching-cadence-issue-resolution>`__ are mostly false positives. To dismiss such issues:

#. `Check whether the CVE was resolved by Ubuntu <https://ubuntu.com/security/cves>`__
#. Check the relevant checkboxes in the table
#. Click the *Other resolutions* dropdown
#. Click the *I cannot reproduce this issue and I think it's incorrect* item
#. Add the comment: *The software is patched/backported.*
#. Click the *Submit* button

"Unsafe Implementation Of Subresource Integrity" is `sometimes unresolvable <https://ocp-software-handbook.readthedocs.io/en/latest/htmlcss/index.html#subresource-integrity-sri>`__. To dismiss such issues:

#. Check the relevant checkboxes in the table
#. Click the *Other resolutions* dropdown
#. Click the *I have compensating controls* item
#. Add a comment like: *Fathom Analytics, Google Analytics, and the Google Fonts API do not support SRI, by design: https://github.com/google/fonts/issues/473#issuecomment-331329601. As a compensating control, we subscribe to Fathom Analytics' and Google's incident alerts.*
#. Click the *Submit* button

WordFence
~~~~~~~~~

WordPress issues are monitored by `WordFence <https://www.wordfence.com/central>`__.

WordFence is managed in each WordPress installation, rather than by visiting its website.

.. _hosting:

Hosting
-------

.. seealso::

   :ref:`backups-snapshots`

Servers are hosted by:

-  `Hetzner <https://robot.hetzner.com/server>`__ for hardware servers (`Network status <https://status.hetzner.com>`__)
-  `Linode <https://cloud.linode.com/>`__ for VPS servers. (`Network status <https://status.linode.com>`__: *Regions > EU-West (London)* and *Backups > EU-West (London) Backups*)
-  `Hetzner Cloud <https://console.hetzner.cloud/>`__ for VPS servers that must be colocated with Hetzner hardware servers
-  `Microsoft Azure <https://portal.azure.com/>`__ for temporary servers for Microsoft-related projects (`Network status <https://azure.status.microsoft/en-us/status>`__)

Unmanaged services are:

-  `Cloudflare Pages <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/workers-and-pages>`__ for static websites (`Network status <https://www.cloudflarestatus.com>`__)

   .. admonition:: Why not GitHub Pages?

      It doesn't allow `custom response headers <https://developers.cloudflare.com/pages/configuration/headers/>`__, notably ``Strict-Transport-Policy`` and ``Content-Security-Policy``.

-  `Heroku <https://dashboard.heroku.com>`__ for the `OCP Library <https://ocp-library.herokuapp.com>`__ and `OCP Form Server <https://survey.open-contracting.org>`__ (`Network status <https://status.heroku.com>`__)

   .. note::

      Heroku is only used for tiny services that can run on `Basic containers <https://www.heroku.com/pricing>`__.

-  `ReadTheDocs <https://readthedocs.org/dashboard/>`__ for project documentation (`Network status <https://status.readthedocs.com>`__)

   .. seealso::

      `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/python/documentation.html#readthedocs>`__ for configuring ReadTheDocs projects

.. _admin-access:

Administrative access
---------------------

.. seealso::

   `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html>`__, for access to third-party services

The server managers are:

-  `Robert Hooper <https://robhooper.net>`__ (`GMT/BST <https://www.timeanddate.com/time/zones/gmt>`__) (servers@robhooper.net) for Linux servers
-  `RBC Group <https://www.rbcgrp.com>`__ (`EET/EEST <https://www.timeanddate.com/time/zones/eet>`__) for Windows servers

`Open Contracting Partnership <https://www.open-contracting.org/about/team/>`__ (OCP) staff also have administrative roles.

.. _root-access-policy:

Root access
~~~~~~~~~~~

Server owners (OCP) and server managers should have root access. Otherwise, only developers who are reasonably expected to deploy to a **development server** should have root access to that server; anyone with root access can grant that developer root access.

Root access should be :ref:`routinely reviewed<review-root-access>`. If a developer did not deploy (and was not granted root access) to a server within the last six months, their root access to that server should be revoked.

The ``ssh.root`` lists in Pillar files and the ``ssh.admin`` list in the ``pillar/common.sls`` file give people access to servers. All people should belong to the above organizations.
