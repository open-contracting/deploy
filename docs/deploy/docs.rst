OCDS documentation tasks
========================

Add a new language
------------------

#. In ``salt/apache/ocds-docs-live.conf.include`` and ``salt/apache/ocds-docs-staging.conf.include``, add the new language in the ``options`` variable.
#. In ``tests/test_docs.py``, update the ``languages`` variable.

.. _add-new-profile:

Add a new profile
-----------------

Below, substitute ``{root}``, ``{latest-branch}``, ``{minor-branch}`` and ``{dev-branch}``. For example: ``ppp``, ``latest`` ``1.0`` and ``1.0-dev``.

#. Edit ``salt/ocds-docs/robots_live.txt``
#. For Googlebot, add:

   .. code-block:: none

      Allow: /profiles/{root}/{latest-branch}

#. If the profile publishes schema files, also add:

   .. code-block:: none

      Allow: /profiles/{root}/schema
      Allow: /profiles/{root}/extension

#. If the profile has a single branch, skip these steps. Otherwise, for all user agents, add:

   .. code-block:: none

      Disallow: /profiles/{root}/{minor-branch}
      Disallow: /profiles/{root}/{dev-branch}

#. If the profile has older versions, also add, for each ``{old-version}``:

   .. code-block:: none

      Disallow: /profiles/{root}/{old-branch}

.. _publish-draft-documentation:

Publish draft documentation
---------------------------

To configure a documentation repository to push builds to the :doc:`staging server<../reference/docs>`:

#. Access the repository’s *Settings* tab
#. Click *Secrets*
#. Set the private key:

   #. Click *Add a new secret*
   #. Set *Name* to "PRIVATE_KEY"
   #. Set *Value* to the contents of ``salt/private/ocds-docs/ssh_authorized_keys_from_travis_private``
   #. Click *Add secret*

#. Set the search secret:

   #. Click *Add a new secret*
   #. Set *Name* to "SEARCH_SECRET"
   #. Set *Value* to the value of the ``OCDS_SECRET`` key in ``pillar/private/standard_search_pillar.sls``
   #. Click *Add secret*

.. _publish-released-documentation:

Publish released documentation
------------------------------

If this is the first numbered version of a profile, in its ``docs/_templates/layout.html``, add:

.. code-block:: none

   {% block version_options %}
   <!--#include virtual="/includes/version-options-profiles-{root}.html" -->
   {% endblock %}

In any case, once the `build passes <https://ocds-standard-development-handbook.readthedocs.io/en/latest/standard/technical/deployment.html#build>`__ for the live branch of the documentation:

1. Copy the files to the live server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each deployment of each branch is given its own directory on the live server, named according to the format ``branch-date-sequence``, for example: ``1.1-2017-08-08-2``. A symlink named after each branch links to the directory to publish for that branch. In this way, you can rollback a deployment by changing the symlink.

Set environment variables, for example:

.. code-block:: bash

   SUBDIR=          # include a trailing slash (leave empty for OCDS documentation)
   VER=1.1          # set to the branch to deploy (not to the tag)
   DATE=$(date +%F) # assuming the build completed today; otherwise, set accordingly
   SEQ=1            # increment for each deploy on the same day

For a profile, set ``SUBDIR`` to, for example, ``profiles/ppp/``. For OC4IDS, set it to ``infrastructure/``.

Copy files from the staging server to your local machine:

.. code-block:: bash

   rsync -avzP root@staging.standard.open-contracting.org:/home/ocds-docs/web/${SUBDIR}${VER}/ ${VER}-${DATE}-${SEQ}

Copy files from your local machine to the live server:

.. code-block:: bash

   rsync -avzP ${VER}-${DATE}-${SEQ} root@live.standard.open-contracting.org:/home/ocds-docs/web/${SUBDIR}/

Symlink the branch:

.. code-block:: bash

   ssh root@live.standard.open-contracting.org "ln -nfs ${VER}-${DATE}-${SEQ} /home/ocds-docs/web/${SUBDIR}${VER}"

If the branch is for the latest version of the documentation, repeat this step with ``VER=latest``.

2. Copy the schema and ZIP file into place
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   You can skip this step if you are not releasing a new major, minor or patch version.

Connect to the server:

.. code-block:: bash

   ssh root@live.standard.open-contracting.org

Set environment variables, for example:

.. code-block:: bash

   SUBDIR=          # include a trailing slash (leave empty for OCDS documentation)
   VER=1.1          # set to the branch as above
   RELEASE=1__1__1  # set to the full release tag name

For a profile, set ``SUBDIR`` to, for example, ``profiles/ppp/``. For OC4IDS, set it to ``infrastructure/``.

For the **OCDS** and **OC4IDS** documentation, run:

.. code-block:: bash

   # Create the directory for the release.
   mkdir /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

   # Copy the schema and codelist files.
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/*.json /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/codelists /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

   # Create a ZIP file of the above.
   cd /home/ocds-docs/web/${SUBDIR}schema/
   zip -r ${RELEASE}.zip ${RELEASE}

The files are then visible at e.g. https://standard.open-contracting.org/schema/1__1__1/.

For a **profile's** documentation, run:

.. code-block:: bash

   # Create the profile and patched directories for the release.
   mkdir -p /home/ocds-docs/web/${SUBDIR}extension/${RELEASE}/ /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

   # Copy the profile's schema and codelist files.
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/*.json /home/ocds-docs/web/${SUBDIR}extension/${RELEASE}/
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/codelists /home/ocds-docs/web/${SUBDIR}extension/${RELEASE}/

   # Create a ZIP file of the above.
   cd /home/ocds-docs/web/${SUBDIR}extension/
   zip -r ${RELEASE}.zip ${RELEASE}

   # Copy the patched schema and codelist files.
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/_static/patched/* /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

3. Update this repository
~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::
   You can skip this step if you are not releasing a new major, minor or patch version.

Below, substitute ``{root}``, ``{latest-branch}``, ``{dev-branch}``, ``{formatted-dev-branch}``, ``{version}`` and ``{name}``. For example: ``ppp``, ``latest``, ``1.0-dev``, ``1.0 Dev``, ``1.0.0.beta`` and ``OCDS for PPPs``.

If this is the first numbered version of a profile:

#. :ref:`Update salt/ocds-docs/robots_live.txt<add-new-profile>`.
#. In ``salt/apache/ocds-docs-live.conf.include``, add the profile's latest branch, minor series and languages in the ``options`` variable.
#. In ``tests/test_docs.py``, update the ``versions``, ``languages`` and ``banner_live`` variables.
#. Add a ``salt/ocds-docs/includes/version-options-profiles-{root}.html`` file to this repository:

   .. code-block:: html

      <option>Version</option>
      <optgroup label="Live">
      <option value="{latest-branch}">{version} ({latest-branch})</option>
      </optgroup>
      <optgroup label="Development Branches">
      <option value="{dev-branch}">{formatted-dev-branch}</option>
      </optgroup>

#. Add a ``salt/ocds-docs/includes/banner_staging_profiles_{root}.html`` file to this repository:

   .. code-block:: html

      <div class="oc-fixed-alert-header">
          This is a development copy of the {name} docs, the <a href="/profiles/{root}/{latest-branch}/en/">latest live version is here</a>.
      </div>

Otherwise:

#. In the appropriate ``salt/ocds-docs/includes/version-options*.html`` file, update the version number in the text of the first ``option`` element.

If this is a new major or minor version:

#. In ``salt/ocds-docs/robots_live.txt``, disallow the minor branch and its dev branch, for example:

   .. code-block:: none

      Disallow: /1.2
      Disallow: /1.2-dev

#. In ``salt/apache/ocds-docs-live.conf.include``, add the minor series in the ``options`` variable, and add a new ``Location`` directive like:

   .. code-block:: none

      <Location /1.1/>
          SetEnv BANNER /includes/banner_old.html
      </Location>

#. In ``tests/test_docs.py``, update the ``versions``, ``banner_live`` and ``banner_old`` variables.
#. In the appropriate ``salt/ocds-docs/includes/banner_staging*.html`` file and ``salt/ocds-docs/includes/banner_old*.html>`` file (if any), update the minor series.
#. In the appropriate ``salt/ocds-docs/includes/version-options*.html`` file, add an ``option`` element to the "Live" ``optgroup`` for the previous minor series and previous version number, for example:

   .. code-block:: html

      <option value="0.9">0.9.2</option>
