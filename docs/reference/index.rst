Reference
=========

.. toctree::
   :caption: Contents
   :maxdepth: 1

   downtime.rst
   docs.rst

Monitoring
----------

Prometheus
~~~~~~~~~~

Servers are monitored by `Prometheus <https://prometheus.io/>`__. Salt is used to:

-  Install a `Node Exporter <https://github.com/prometheus/node_exporter>`__ service on each server, to export hardware and OS metrics like disk space used, memory used, etc.
-  Set up a Prometheus server to collect metrics from all servers, and to email alerts if metrics are out of bounds

Read the :doc:`user guide <../use/prometheus>` to learn how to use Prometheus.

DMARC Analyzer
~~~~~~~~~~~~~~

OCP's `DMARC policy <https://support.google.com/a/answer/2466563>`__ (``dig TXT _dmarc.open-contracting.org``) sends aggregate and forensic reports to `DMARC Analyzer <https://app.dmarcanalyzer.com/>`__.

Google Postmaster Tools
~~~~~~~~~~~~~~~~~~~~~~~

`Google Postmaster Tools <https://postmaster.google.com/managedomains>`__ can be used to `debug deliverability issues <https://support.google.com/mail/answer/9981691>`__ from AWS to GMail.

Sentry
~~~~~~

Application errors are reported to `Sentry <https://sentry.io/organizations/open-contracting-partnership/projects/>`__, which notifies individual email addresses. All Salt-managed, OCP-authored services report errors to Sentry.

See the `Software Development Handbook <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html#sentry>`__ for access to Sentry.

.. _hosting:

Hosting
-------

All servers (not services) are managed by `Dogsbody Technology <https://www.dogsbody.com>`__ (sysadmin@dogsbody.com). Servers are hosted by:

-  `Hetzner <https://robot.your-server.de/server>`__ for hardware servers, including Kingfisher and Registry

   -  `Network status <https://www.hetzner-status.de/en.html>`__

-  `Linode <https://cloud.linode.com/>`__ for VPS servers provisioned after August 2021

   -  `Network status <https://status.linode.com/>`__: The relevant systems are: Regions: EU-West (London), Backups: EU-West (London) Backups.
   -  **Access**: The 'opencontractingpartnership' and 'opencontracting-dogsbody' users have full access.
   -  **Backups**: It is configured to have one daily backup and two weekly backups. Dogsbody also configured daily and weekly backups to `Google Cloud Platform <https://ocp-software-handbook.readthedocs.io/en/latest/services/admin.html#cloud-platform>`__.

Unmanaged services are:

-  GitHub Pages for the `Extension Explorer <https://extensions.open-contracting.org/>`__

   -  `Network status <https://www.githubstatus.com>`__

-  Heroku for the `OCP Library <http://ocp-library.herokuapp.com>`__

   -  `Network status <https://status.heroku.com>`__

Administrative access
---------------------

See the `Software Development Handbook <https://ocdsdeploy.readthedocs.io/en/latest/reference/index.html>`__ for access to third-party services.

The staff of the following organizations have had administrative roles:

-  `Open Contracting Partnership <https://www.open-contracting.org/about/team/>`__ (OCP)
-  `Centro de Desarrollo Sostenible <http://www.cds.com.py>`__ (CDS)
-  `Datlab <https://datlab.eu>`__
-  `Dogsbody Technology <https://www.dogsbody.com>`__
-  `Open Data Services Co-operative <https://opendataservices.coop>`__ (ODS)
-  `Quintagroup <https://quintagroup.com>`__
-  `Young Innovations <https://younginnovations.com.np>`__

The ``ssh.root`` lists in Pillar files and the ``ssh.admin`` list in the ``pillar/common.sls`` file give people access to servers. All people should belong to the above organizations.

.. _root-access-policy:

Root access
~~~~~~~~~~~

Server owners (OCP) and server managers (Dogsbody) should have root access to all servers. Otherwise, only developers who are reasonably expected to deploy to a server should have root access to that server.

If a developer did not deploy (and was not granted root access) to a server within the last six months, their root access to that server should be revoked.

If a developer intends to deploy to a server, anyone with root access can grant that developer root access to that server.

Root access should be :ref:`routinely reviewed<review-root-access>`.

Redash
~~~~~~

There should be a minimum of two `admin <https://redash.open-contracting.org/groups/1>`__ members from OCP only.

Users should belong to a single group. Non-admin staff of OCP should belong to the `unrestricted <https://redash.open-contracting.org/groups/5>`__ group.

Redmine CRM
~~~~~~~~~~~

There should be a minimum of two `Administrator <https://crm.open-contracting.org/users?sort=admin%3Adesc%2Clogin>`__ roles from OCP only.

See the `process documentation <https://docs.google.com/document/d/1h68dx7fSszAJMkNjR0_rIK2iivzv4s5Nvu-C0fUj380/edit>`__ for access to Redmine CRM.
