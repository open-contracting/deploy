OCDS documentation
==================

.. seealso::

   :ref:`Migrate OCDS documentation to a new server <migrate-server>`

Add a new language
------------------

#. In ``salt/apache/files/sites/docs.conf.include``, add the new language in the ``options`` variable.
#. In ``tests/test_docs.py``, update the ``languages`` variable.

.. _add-new-profile:

Add a new minor version
-----------------------

Below, substitute ``{root}``, ``{current-minor-branch}`` and ``{old-minor-branch}``. For example: ``ppp``, ``1.1`` and ``1.0``.

#. Edit ``salt/apache/files/docs/robots.txt``

#. If the profile has a version, add:

   .. code-block:: none

      Disallow: /profiles/{root}/{current-minor-branch}

#. If the profile has older minor versions, also add, for each old minor version:

   .. code-block:: none

      Disallow: /profiles/{root}/{old-minor-branch}

.. _publish-draft-documentation:

Publish draft documentation
---------------------------

To configure a documentation repository to push builds to the server:

#. Access the repository’s *Settings* tab
#. Click *Secret and variables*
#. Click *Actions*
#. Set the private key:

   #. Click *New repository secret*
   #. Set *Name* to "PRIVATE_KEY"
   #. Set *Value* to the contents of ``salt/private/keys/docs_ci``
   #. Click *Add secret*

#. Set the Elasticsearch password:

   #. Click *New repository secret*
   #. Set *Name* to "ELASTICSEARCH_PASSWORD"
   #. Set *Value* to the password of the ``manage`` user in the ``pillar/private/docs.sls`` file
   #. Click *Add secret*

.. _publish-released-documentation:

Publish released documentation
------------------------------

Follow the OCDS Development Handbook's `deployment guide <https://ocds-standard-development-handbook.readthedocs.io/en/latest/standard/technical/deployment.html>`__.


1. Update this repository
~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::
   You can skip this step if you are not releasing a new major, minor or patch version.

Below, substitute ``{root}``, ``{latest-branch}``, ``{dev-branch}``, ``{formatted-dev-branch}``, ``{version}`` and ``{name}``. For example: ``ppp``, ``latest``, ``1.0-dev``, ``1.0 Dev``, ``1.0.0.beta`` and ``OCDS for PPPs``.

**If this is the first numbered version of a profile:**

#. :ref:`Update salt/docs/robots.txt<add-new-profile>`.
#. In ``salt/apache/files/sites/docs.conf.include``, add the profile's latest branch, minor series and languages in the ``options`` variable.
#. In ``tests/test_docs.py``, update the ``versions``, ``languages`` and ``banner_live`` variables.
#. Add a ``salt/docs/includes/version-options-profiles-{root}.html`` file to this repository:

   .. code-block:: html

      <option>Version</option>
      <option value="{latest-branch}">{version} ({latest-branch})</option>

#. Add a ``salt/docs/includes/banner_staging_profiles_{root}.html`` file to this repository:

   .. code-block:: html

      <div class="oc-fixed-alert-header">
          This is a development copy of the {name} docs, the <a href="/profiles/{root}/{latest-branch}/en/">latest live version is here</a>.
      </div>

**Otherwise:**

#. In the appropriate ``salt/docs/includes/version-options*.html`` file, update the version number in the text of the first ``option`` element.

**If this is a new major or minor version:**

#. In ``salt/docs/robots.txt``, disallow the minor branch and its dev branch, for example:

   .. code-block:: none

      Disallow: /1.2
      Disallow: /1.2-dev

#. In ``salt/apache/files/sites/docs.conf.include``, add the minor series in the ``options`` variable, and add a new ``Location`` directive like:

   .. code-block:: apache

      <Location /1.1/>
          SetEnv BANNER /includes/banner_old.html
      </Location>

#. In ``ocdsindex-exclude.txt``, add the base URL of the new version.
#. In ``tests/test_docs.py``, update the ``versions``, ``banner_live`` and ``banner_old`` variables.
#. In the appropriate ``salt/docs/includes/banner_staging*.html`` file and ``salt/docs/includes/banner_old*.html>`` file (if any), update the minor series.
#. In the appropriate ``salt/docs/includes/version-options*.html`` file, add an ``option`` element to the "Live" ``optgroup`` for the previous minor series and previous version number, for example:

   .. code-block:: html

      <option value="0.9">0.9.2</option>

2. Update other repositories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

`Update the Data Review Tool <https://ocds-standard-development-handbook.readthedocs.io/en/latest/standard/technical/deployment.html#update-the-data-review-tool>`__ and any other tools per `this spreadsheet <https://docs.google.com/spreadsheets/d/18Pq5Hyyk4bNQ_mIaCRqGqwut4ws2_cIh0UYQNAYKv-A/edit#gid=0>`__.

.. _docs-migrate:

Migrate from an old server
--------------------------

#. Copy the ``/home/ocds-docs/web`` directory. For example:

   .. code-block:: bash

      rsync -avz ocp99:/home/ocds-docs/web/ /home/ocds-docs/web/

#. Stop Elasticsearch, replace the ``/var/lib/elasticsearch/`` directory, and start Elasticsearch. For example:

   .. code-block:: bash

      systemctl stop elasticsearch
      rm -rf /var/lib/elasticsearch/*
      rsync -avz ocp99:/var/lib/elasticsearch/ /var/lib/elasticsearch/
      systemctl start elasticsearch

#. Mark the ``elasticsearch`` package as held back:

   .. code-block:: bash

      apt-mark hold elasticsearch
