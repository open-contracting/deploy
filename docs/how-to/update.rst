Update server configurations
============================

1. Update private templates
---------------------------

If you add, remove or rename a file or variable in ``pillar/private`` or ``salt/private``, replicate the changes in ``pillar/private-templates`` or ``salt/private-templates``.

This allows others to use this repository to, for example, deploy Kingfisher to their own servers.

2. Test changes
---------------

To test changes to the Apache files for the :ref:`ocds-documentation` (for example, to test new redirects or proxy settings):

#. Make changes inside ``{% if testing %}`` blocks in the config files
#. :doc:`Deploy<deploy>` the OCDS Documentation
#. Visit the testing version of the `live website <http://testing.live.standard.open-contracting.org/>`__ or `staging website <http://testing.staging.standard.open-contracting.org/>`__

To run the automated tests for the OCDS documentation (using the fish shell):

.. code-block:: bash

   pip install -r requirements.txt
   env FQDN=testing.live.standard.open-contracting.org pytest

The tests should pass if ``FQDN`` is omitted or set to standard.open-contracting.org.

Once satisfied, move the changes outside ``{% if testing  %}`` blocks.

3. Review code
--------------

For context, for other repositories, work is done on a branch and tested on a local machine before a pull request is made, which is then tested on Travis CI, reviewed and approved before merging.

However, for this repository, in some cases, it's impossible to test changes to server configurations, for example: if SSL certificates are involved (because certbot can't verify a virtual machine), or if external services like Travis are involved. In other cases, it's too much effort to setup a test environment in which to test changes.

In such cases, the same process is followed as in other repositories, but without the benefit of tests.

In entirely uncontroversial or time-sensitive cases, work is done on the ``master`` branch, deployed to servers, and committed to the ``master`` branch once successful. In cases where the changes require trial and error, the general approach is discussed in a GitHub issue, and then work is done on the ``master`` branch as above. Developers can always request informal reviews from colleagues.

Take extra care when making larger changes or when making changes to `higher-priority apps <https://github.com/open-contracting/standard-maintenance-scripts/blob/master/badges.md>`__.

Check history
-------------

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. You can `browse <https://github.com/OpenDataServices/opendataservices-deploy/tree/7a5baff013b888c030df8366b3de45aae3e12f9e>`__ that repository from before the change (August 5, 2019). That repository was itself re-organized at different times. You can browse: `before moving content from *.conf to *.conf.include <https://github.com/OpenDataServices/opendataservices-deploy/tree/4dbea5122e1fc01221c8d051efc99836cef98ccb>`__ (June 5, 2019).

Track upstream
--------------

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. Some common files might have improvements in the original repository. To check for updates, run:

.. code-block:: bash

   git clone git@github.com:OpenDataServices/opendataservices-deploy.git
   git log --name-status setup_for_non_root.sh updateToMaster.sh Saltfile pillar/common_pillar.sls pillar/staging_pillar.sls salt-config/master salt/apache-proxy.sls salt/apache.sls salt/apache/000-default.conf salt/apache/000-default.conf.include salt/apache/_common.conf salt/apache/cove.conf salt/apache/cove.conf.include salt/apache/prometheus-client.conf salt/apache/prometheus-client.conf.include salt/apache/robots_dev.txt salt/apt/10periodic salt/apt/50unattended-upgrades salt/core.sls salt/cove.sls salt/fail2ban/action.d/mail-whois.local salt/fail2ban/filter.d/uwsgi.conf salt/letsencrypt.sls salt/lib.sls salt/nginx/redash salt/prometheus-client-apache.sls salt/prometheus-client/prometheus-node-exporter.service salt/system/ocdskingfisher_motd salt/uwsgi.sls salt/uwsgi/cove.ini

-  ``setup_for_non_root.sh`` corresponds to ``script/setup``
-  ``updateToMaster.sh`` corresponds to ``script/update``
-  ``salt-config/roster``, ``pillar/top.sls``, ``salt/top.sls`` and ``pillar/live_pillar.sls`` are common files, but are unlikely to contain improvements

This repository has all improvements up to September 30, 2019.
