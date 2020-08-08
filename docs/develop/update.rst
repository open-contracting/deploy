Make changes
============

Most changes are deployed when :doc:`deploying a service<../deploy/deploy>`. However, some changes require :doc:`additional steps<../deploy/update>`.

1. Test changes
---------------

To preview what is going to change, use `test=True <https://docs.saltstack.com/en/latest/ref/states/testing.html>`__, for example:

.. code-block:: bash

   salt-ssh 'ocds-docs-live' state.apply test=True

To preview changes to a Pillar file, run, for example:

.. code-block:: bash

   salt-ssh 'ocds-docs-live' pillar.items

To compare Jinja2 output after refactoring but before committing, use ``script/diff`` to compare a full state or one SLS file, for example:

.. code-block:: bash

   ./script/diff ocds-docs-staging
   ./script/diff ocds-docs-staging ocds-docs-common

If you get the error, ``An Exception occurred while executing state.show_highstate: 'list' object has no attribute 'values'``, run ``state.apply test=True`` as above. You might have conflicting IDs.

Using a testing virtual host
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To test changes to the Apache files for the :doc:`../reference/docs` (for example, to test new redirects or proxy settings):

#. Make changes inside ``{% if testing %}`` blocks in the config files
#. :doc:`Deploy<../deploy/deploy>` the OCDS Documentation
#. To test manually, visit the testing version of the `live website <http://testing.live.standard.open-contracting.org/>`__ or `staging website <http://testing.staging.standard.open-contracting.org/>`__
#. To test automatically, run (using the fish shell):

.. code-block:: bash

   pip install -r requirements.txt
   env FQDN=testing.live.standard.open-contracting.org pytest

Update the tests if you changed the behavior of the Apache files.

Once satisfied, move the changes outside ``{% if testing  %}`` blocks. After deployment, the tests should pass if ``FQDN`` is omitted or set to standard.open-contracting.org.

.. _using-a-virtual-machine:

Using a virtual machine
~~~~~~~~~~~~~~~~~~~~~~~

#. `Create a virtual machine <https://docs.saltstack.com/en/getstarted/ssh/system.html>`__
#. Get the virtual machine's IP address

   - If using VirtualBox, run (replacing ``VMNAME``):

     .. code-block:: bash

        VBoxManage guestproperty get VMNAME "/VirtualBox/GuestInfo/Net/0/V4/IP"

#. Update the relevant target in ``salt-config/roster`` to point to the virtual machine's IP address
#. In the relevant Pillar file, change ``https`` to ``no``, if certbot is used to enable HTTPS
#. Edit ``/etc/hosts`` to map the virtual machine's IP address to the service's hostname
#. Deploy to the virtual machine and test

Note that Python errors that occur on the virtual machine might still be reported to Sentry. The ``server_name`` tag in any error reports is expected to be different, but the error reports might still confuse other developers who don't know to check that tag.

2. Review code
--------------

For context, for other repositories, work is done on a branch and tested on a local machine before a pull request is made, which is then tested on continuous integration, reviewed and approved before merging.

However, for this repository, in some cases, it's impossible to test changes to server configurations, for example: if SSL certificates are involved (because certbot can't verify a virtual machine), or if external services are involved. In other cases, it's too much effort to setup a test environment in which to test changes.

In such cases, the same process is followed as in other repositories, but without the benefit of tests.

In entirely uncontroversial or time-sensitive cases, work is done on the ``master`` branch, deployed to servers, and committed to the ``master`` branch once successful. In cases where the changes require trial and error, the general approach is discussed in a GitHub issue, and then work is done on the ``master`` branch as above. Developers can always request informal reviews from colleagues.

Take extra care when making larger changes or when making changes to `higher-priority apps <https://github.com/open-contracting/standard-maintenance-scripts/blob/master/badges.md>`__.

.. _change-server-name:

Track upstream
--------------

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. Some common files might have improvements in the original repository. To check for updates, run:

.. code-block:: bash

   git clone git@github.com:OpenDataServices/opendataservices-deploy.git
   cd opendataservices-deploy
   git log --name-status setup_for_non_root.sh updateToMaster.sh Saltfile pillar/common_pillar.sls salt-config/master salt/apache.sls salt/apache/000-default.conf salt/apache/000-default.conf.include salt/apache/_common.conf salt/apache/cove.conf salt/apache/cove.conf.include salt/apache/prometheus-client.conf salt/apache/prometheus-client.conf.include salt/apache/robots_dev.txt salt/apt/10periodic salt/apt/50unattended-upgrades salt/core.sls salt/cove.sls salt/letsencrypt.sls salt/lib.sls salt/nginx/redash salt/prometheus-client-apache.sls salt/prometheus-client/prometheus-node-exporter.service salt/system/ocdskingfisher_motd salt/uwsgi.sls salt/uwsgi/cove.ini

-  ``setup_for_non_root.sh`` corresponds to ``script/setup``
-  ``updateToMaster.sh`` corresponds to ``script/update``
-  ``salt-config/roster``, ``pillar/top.sls`` and ``salt/top.sls`` are common files, but are unlikely to contain improvements

This repository has all improvements up to September 30, 2019.
