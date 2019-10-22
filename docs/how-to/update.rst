Update server configurations
============================

1. Update private templates
---------------------------

If you add, remove or rename a file or variable in ``pillar/private`` or ``salt/private`` (but not if you change the value of a variable), replicate the changes in ``pillar/private-templates`` and ``salt/private-templates``. (This makes it easier for others to use this repository to, for example, deploy Kingfisher to their own servers.)

2. Test changes
---------------

To test changes to the Apache files for the :ref:`ocds-documentation` (for example, new redirects or proxy settings), you can make changes inside ``{% if testing  %}`` blocks in the config files. After deploying, visit the testing version of the live website or staging website:

-  http://testing.live.standard.open-contracting.org/
-  http://testing.staging.standard.open-contracting.org/

Once satisfied, move the changes outside ``{% if testing  %}`` blocks.

3. Review code
--------------

For context, for other repositories, work is done on a branch and tested on a local machine before a pull request is made, which is then tested on Travis CI, reviewed and approved before merging.

However, for this repository, in some cases, it's impossible to test changes to server configurations, for example: if SSL certificates are involved (because certbot can't verify a virtual machine), or if external services like Travis are involved. In other cases, it's too much effort to setup a test environment in which to test changes.

In such cases, the same process is followed as in other repositories, but without the benefit of tests.

In entirely uncontroversial or time-sensitive cases, work is done on the ``master`` branch, deployed to servers, and committed to the ``master`` branch once successful. In cases where the changes require trial and error, the general approach is discussed in a GitHub issue, and then work is done on the ``master`` branch as above. Developers can always request informal reviews from colleagues.

Take extra care when making larger changes or when making changes to `higher-priority apps <https://github.com/open-contracting/standard-maintenance-scripts/blob/master/badges.md>`__.
