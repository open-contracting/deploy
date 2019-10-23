OCDS Documentation
==================

Add a new language
------------------

In ``salt/apache/ocds-docs-live.conf.include`` and ``salt/apache/ocds-docs-staging.conf.include``, add the new language to the ``langs`` variable.

Add a new profile
-----------------

Below, substitute ``{root}`` and ``{latest-branch}``. For example: ``ppp`` and ``latest``.

#. Edit ``salt/ocds-docs/robots_live.txt``
#. Add ``Allow: /profiles/{root}/{latest-branch}``
#. Add ``Disallow: /profiles/{root}/{latest-branch}/switcher``

.. _publish-draft-documentation:

Publish draft documentation
---------------------------

To configure a documentation repository to push builds to the :ref:`staging server<ocds-documentation>`:

#. Access the repository’s Travis page
#. Click "More options" and "Settings"
#. Set the private key:

   #. Enter "PRIVATE_KEY" in the first input under "Environment Variables"
   #. Get the ``ocds-docs`` user’s private key (`deploy-docs.sh <https://github.com/open-contracting/deploy/blob/master/deploy-docs.sh>`__ will restore the newlines and spaces):

      .. code-block:: bash

         cat salt/private/ocds-docs/ssh_authorized_keys_from_travis_private | tr '\n' '#' | tr ' ' '_'

   #. Enter the private key in the second input
   #. Click "Add"

#. Set the search secret:

   #. Enter "SEARCH_SECRET" in the first input under "Environment Variables"
   #. Get the value of the ``ocds_secret`` key in ``pillar/private/standard_search_pillar.sls``
   #. Enter it in the second input
   #. Click "Add"

.. _publish-released-documentation:

Publish released documentation
------------------------------

If this is the first numbered version of a profile, in its ``docs/_templates/layout.html``, add:

.. code-block:: html

   {% block version_options %}
   <!--#include virtual="/includes/version-options-profiles-{root}.html" -->
   {% endblock %}

In any case, once the `build passes on Travis <https://ocds-standard-development-handbook.readthedocs.io/en/latest/standard/technical/deployment.html#build-on-travis>`__ for the live branch of the documentation:

1. Copy the files to the live server
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Each deployment of each branch is given its own directory on the live server, named according to the format ``branch-date-sequence``, for example: ``1.1-2017-08-08-2``. A symlink named after each branch links to the directory to publish for that branch. In this way, you can rollback a deployment by changing the symlink.

Set environment variables, for example:

.. code-block:: bash

   SUBDIR=          # leave empty for OCDS documentation
   VER=1.1          # set to the branch to deploy
   DATE=$(date +%F) # assuming the build completed today; otherwise, set accordingly
   SEQ=1            # increment for each deploy on the same day

For a profile, set ``SUBDIR`` to, for example, ``profiles/ppp/``. For OC4IDS, set it to ``infrastructure/``.

Copy files from the staging server to your local machine:

.. code-block:: bash

   scp -r root@staging.standard.open-contracting.org:/home/ocds-docs/web/${SUBDIR}${VER} ${VER}-${DATE}-${SEQ}

Copy files from your local machine to the live server:

.. code-block:: bash

   scp -r ${VER}-${DATE}-${SEQ} root@live.standard.open-contracting.org:/home/ocds-docs/web/${SUBDIR}

Symlink the branch:

.. code-block:: bash

   ssh root@live.standard.open-contracting.org "ln -sf ${VER}-${DATE}-${SEQ} /home/ocds-docs/web/${SUBDIR}${VER}"

If the branch is for the latest version of the documentation, repeat this step with ``VER=latest``.

2. Copy the schema and ZIP file into place
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   You can skip this step if you are not releasing a new major, minor or patch version.

Login to the server:

.. code-block:: bash

   ssh root@live.standard.open-contracting.org

Set environment variables, for example:

.. code-block:: bash

   SUBDIR=          # leave empty for OCDS documentation
   VER=1.1          # set to the branch as above
   RELEASE=1__1__1  # set to the full release tag name

For a profile, set ``SUBDIR`` to, for example, ``profiles/ppp/``. For OC4IDS, set it to ``infrastructure/``.

For the OCDS and OC4IDS documentation, run:

.. code-block:: bash

   # Create the directory for the release.
   mkdir /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

   # Copy the schema and codelist files.
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/*.json /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/
   cp -r /home/ocds-docs/web/${SUBDIR}${VER}/en/codelists /home/ocds-docs/web/${SUBDIR}schema/${RELEASE}/

   # Create a ZIP file of the above.
   cd /home/ocds-docs/web/schema/
   zip -r ${RELEASE}.zip ${RELEASE}

The files are then visible at e.g. https://standard.open-contracting.org/schema/1__1__1/.

For a profile's documentation, run:

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

Below, substitute ``{root}``, ``{latest-branch}``, ``{dev-branch}``, ``{formatted-dev-branch}`` and ``{version}``. For example: ``ppp``, ``latest``, ``1.0-dev``, ``1.0 Dev`` and ``1.0.0.beta``.

If this is the first numbered version of a profile:

#. In ``salt/apache/ocds-docs-live.conf.include``, add the profile's languages to the ``langs`` variable, and add its latest branch and minor series to the ``profile_versions`` variable.

#. Add a ``salt/ocds-docs/includes/version-options-profiles-{root}.html`` file to this repository:

   .. code-block:: html

      <option>Version</option>
      <optgroup label="Live">
      <option value="{latest-branch}">{version} ({latest-branch})</option>
      </optgroup>
      <optgroup label="Development Branches">
      <option value="{dev-branch}">{formatted-dev-branch}</option>
      </optgroup>

Otherwise:

#. In the appropriate ``salt/ocds-docs/includes/version-options*.html`` file, update the version number in the text of the first ``option`` element.

If this is a new major or minor version:

#. In ``salt/apache/ocds-docs-live.conf.include``, add the documentations's minor series to the appropriate ``*_versions`` variable.

#. In the appropriate ``salt/ocds-docs/includes/banner_staging*.html`` file and ``salt/ocds-docs/includes/banner_old*.html>`` file (if any), update the minor series.

#. In the appropriate ``salt/ocds-docs/includes/version-options*.html`` file, add an ``option`` element to the "Live" ``optgroup`` for the previous minor series and previous version number, for example:

   .. code-block:: html

      <option value="0.9">0.9.2</option>
