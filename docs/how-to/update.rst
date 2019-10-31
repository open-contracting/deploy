Update server configurations
============================

1. Update private templates
---------------------------

If you add, remove or rename a file or variable in ``pillar/private`` or ``salt/private``, replicate the changes in ``pillar/private-templates`` or ``salt/private-templates``.

This allows others to use this repository to, for example, deploy Kingfisher to their own servers.

2. Test changes
---------------

To preview what is going to change, use `test=True <https://docs.saltstack.com/en/latest/ref/states/testing.html>`__, for example:

.. code-block:: bash

   salt 'ocds-docs-live' state.apply test=True

To compare Jinja2 output after refactoring, run, for example:

.. code-block::bash

   git stash
   salt-ssh 'toucan' state.show_sls toucan > before
   git stash pop
   salt-ssh 'toucan' state.show_sls toucan > after
   diff -u before after
   rm -f before after

Using a testing virtual host
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To test changes to the Apache files for the :ref:`ocds-documentation` (for example, to test new redirects or proxy settings):

#. Make changes inside ``{% if testing %}`` blocks in the config files
#. :doc:`Deploy<deploy>` the OCDS Documentation
#. To test manually, visit the testing version of the `live website <http://testing.live.standard.open-contracting.org/>`__ or `staging website <http://testing.staging.standard.open-contracting.org/>`__
#. To test automatically, run (using the fish shell):

.. code-block:: bash

   pip install -r requirements.txt
   env FQDN=testing.live.standard.open-contracting.org pytest

Update the tests if you changed the behavior of the Apache files.

Once satisfied, move the changes outside ``{% if testing  %}`` blocks. After deployment, the tests should pass if ``FQDN`` is omitted or set to standard.open-contracting.org.

Using a virtual machine
~~~~~~~~~~~~~~~~~~~~~~~

#. `Create a virtual machine <https://docs.saltstack.com/en/getstarted/ssh/system.html>`__
#. Update the relevant targets in ``salt-config/roster`` to point to the virtual machine
#. Deploy to the virtual machine and test

3. Review code
--------------

For context, for other repositories, work is done on a branch and tested on a local machine before a pull request is made, which is then tested on Travis CI, reviewed and approved before merging.

However, for this repository, in some cases, it's impossible to test changes to server configurations, for example: if SSL certificates are involved (because certbot can't verify a virtual machine), or if external services like Travis are involved. In other cases, it's too much effort to setup a test environment in which to test changes.

In such cases, the same process is followed as in other repositories, but without the benefit of tests.

In entirely uncontroversial or time-sensitive cases, work is done on the ``master`` branch, deployed to servers, and committed to the ``master`` branch once successful. In cases where the changes require trial and error, the general approach is discussed in a GitHub issue, and then work is done on the ``master`` branch as above. Developers can always request informal reviews from colleagues.

Take extra care when making larger changes or when making changes to `higher-priority apps <https://github.com/open-contracting/standard-maintenance-scripts/blob/master/badges.md>`__.

Remove content
--------------

If you delete a service, package, user, or authorized key from file, it will not be removed from the server. To remove it, after you :doc:`deploy <deploy>`:

Delete an authorized key
~~~~~~~~~~~~~~~~~~~~~~~~

#. Cut it from ``salt/private/authorized_keys/root_to_add`` and paste it into ``salt/private/authorized_keys/root_to_remove``
#. Run:

   .. code-block:: bash

      salt-ssh '*' state.sls_id root_authorized_keys_add core
      salt-ssh '*' state.sls_id root_authorized_keys_remove core

#. Delete it from ``salt/private/authorized_keys/root_to_remove``

Delete a service
~~~~~~~~~~~~~~~~

`Stop <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.stop>`__ and `disable <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.disable>`__ the service. For example, to stop and disable the ``icinga2`` service on the ``ocds-docs-staging`` target:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' service.stop icinga2
   salt-ssh 'ocds-docs-staging' service.disable icinga2

Delete a package
~~~~~~~~~~~~~~~~

`Remove a package and its configuration files <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.purge>`__, and `remove any of its dependencies that are no longer needed <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.autoremove>`__. For example, to scrub Icinga-related packages from the ``ocds-docs-staging`` target:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.purge icinga2,nagios-plugins,nagios-plugins-contrib
   salt-ssh 'ocds-docs-staging' pkg.autoremove list_only=True
   salt-ssh 'ocds-docs-staging' pkg.autoremove purge=True

Then, login to the server and check for and delete any remaining packages, files or directories relating to the package:

.. code-block:: bash

   dpkg -l | grep icinga
   dpkg -l | grep nagios
   ls /etc/icinga2
   ls /usr/lib/nagios

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
