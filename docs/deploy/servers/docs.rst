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

#. :ref:`Update salt/apache/files/docs/robots.txt<add-new-profile>`.
#. In ``salt/apache/files/sites/docs.conf.include``, add the profile's latest branch, minor series and languages in the ``options`` variable.
#. In ``salt/docs/init.sls``, add the profile to the ``documentation`` variable:

   .. code-block:: none

      'profiles/{root}/': [
          {'ref': '{latest-branch}', 'label': '{version} ({latest-branch})'},
      ],

#. In ``tests/test_docs.py``, update the ``versions``, ``languages`` and ``switcher_versions`` variables.

**Otherwise:**

#. In ``salt/docs/init.sls``, update the version's ``label`` in the ``documentation`` variable.

**If this is a new major or minor version:**

#. In ``salt/apache/files/docs/robots.txt``, disallow the minor branch and its dev branch, for example:

   .. code-block:: none

      Disallow: /1.2
      Disallow: /1.2-dev

#. In ``salt/apache/files/sites/docs.conf.include``, add the minor series in the ``options`` variable.
#. In ``ocdsindex-exclude.txt``, add the base URL of the new version.
#. In ``tests/test_docs.py``, update the ``versions``, ``banner_old`` and ``switcher_versions`` variables.
#. In ``salt/docs/init.sls``, add the previous minor series to the root's entry in the ``documentation`` variable, after the current version, for example:

   .. code-block:: none

      {'ref': '0.9', 'label': '0.9.2'},

   Listing it is what makes its pages show the old-version banner and offer it in the version switcher.

#. If the root is ``/``, update the version in ``salt/apache/files/docs/includes/banner_old.html``, which the frozen ``/1.0/`` still reads.

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

#. Replace the hostname (``ocp##.open-contracting.org``) and public key in ``deploy-docs.sh``.
#. Replace the hostname in ``ci-profile.yml`` in the `.github <https://github.com/open-contracting/.github/blob/main/.github/workflows/ci-profile.yml>`__ repository.
