Reference
=========

.. toctree::
   :caption: Contents
   :maxdepth: 1

   downtime.rst
   docs.rst
   powerbi.rst

Monitoring
----------

.. seealso::

   :doc:`../deploy/google`

Ahrefs
~~~~~~

SEO issues are audited by Ahrefs.com's `Site Audit <https://ahrefs.com/site-audit>`__. Access the `most recent crawl <https://app.ahrefs.com/site-audit/4835895>`__:

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

Prometheus
~~~~~~~~~~

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Salt is used to:

-  Install a `Node Exporter <https://github.com/prometheus/node_exporter>`__ service on each server, to export hardware and OS metrics like disk space used, memory used, etc.
-  Set up a Prometheus server to collect metrics from all servers, and to email alerts if metrics are out of bounds

Read the :doc:`user guide <../use/prometheus>` to learn how to use Prometheus.

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

   -  `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html#sentry>`__ for access to Sentry
   -  `Sentry search reference <https://docs.sentry.io/concepts/search/>`__

SecurityScorecard
~~~~~~~~~~~~~~~~~

Cybersecurity issues are monitored by `SecurityScorecard <https://platform.securityscorecard.io>`__. `Patching cadence issues <https://support.securityscorecard.com/hc/en-us/articles/115002965683-Patching-cadence-issue-resolution>`__ are mostly false positives. To dismiss such issues:

#. Check the checkboxes in the table
#. Click the *Other resolutions* dropdown
#. Click the *I cannot reproduce this issue and I think it's incorrect* item
#. Add the comment: *The software is patched/backported.*
#. Click the *Submit* button

.. _hosting:

Hosting
-------

All servers (not services) are managed by `Dogsbody Technology <https://www.dogsbody.com>`__ (sysadmin@dogsbody.com). Servers are hosted by:

-  `Hetzner <https://robot.hetzner.com/server>`__ for hardware servers (`Network status <https://status.hetzner.com>`__)

-  `Linode <https://cloud.linode.com/>`__ for VPS servers

   -  `Network status <https://status.linode.com/>`__: The relevant systems are: Regions: EU-West (London), Backups: EU-West (London) Backups.
   -  **Access**: The 'opencontractingpartnership' and 'opencontracting-dogsbody' users have full access.
   -  **Backups**: It is configured to have one daily backup and two weekly backups.

Unmanaged services are:

-  `Cloudflare Pages <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/workers-and-pages>`__ for static websites (`Network status <https://www.cloudflarestatus.com>`__)

   .. admonition:: Why not GitHub Pages?

      GitHub Pages does not allow `custom response headers <https://developers.cloudflare.com/pages/configuration/headers/>`__, notably ``Strict-Transport-Policy`` (HSTS) and ``Content-Security-Policy`` (CSP).

-  Heroku for the `OCP Library <https://ocp-library.herokuapp.com>`__ (`Network status <https://status.heroku.com>`__)

.. seealso::

   `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html>`__ for access to Cloudflare and Heroku

Administrative access
---------------------

.. seealso::

   `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html>`__, for access to third-party services

The staff of the following organizations have had administrative roles:

-  `Open Contracting Partnership <https://www.open-contracting.org/about/team/>`__ (OCP)
-  `Dogsbody Technology <https://www.dogsbody.com>`__
-  `RBC Group <https://www.rbcgrp.com>`__

.. _root-access-policy:

Root access
~~~~~~~~~~~

Server owners (OCP) and server managers (Dogsbody for Linux, RBC for Windows) should have root access. Otherwise, only developers who are reasonably expected to deploy to a **development server** should have root access to that server; anyone with root access can grant that developer root access.

Root access should be :ref:`routinely reviewed<review-root-access>`. If a developer did not deploy (and was not granted root access) to a server within the last six months, their root access to that server should be revoked.

The ``ssh.root`` lists in Pillar files and the ``ssh.admin`` list in the ``pillar/common.sls`` file give people access to servers. All people should belong to the above organizations.
