Update server configurations
============================

Code review
-----------

For other repositories, work is done on a branch and tested on a local machine before a pull request is made, which is then reviewed and approved before merging.

However, for this repository, in some cases, it's impossible to test changes to server configurations, for example: if SSL certificates are involved (because certbot can't verify a virtual machine), or if external services like Travis are involved. In other cases, it's too much effort to setup a test environment in which to test changes.

In such cases, the same process is followed as in other repositories, but without the benefit of tests.

In entirely uncontroversial or time-sensitive cases, work is done on the ``master`` branch, deployed to servers, and committed to the ``master`` branch once successful. In cases where the changes require trial and error, the general approach is discussed in a GitHub issue, and then work is done on the ``master`` branch as above. Developers can always request informal review from colleagues.

Take extra care when making larger changes or when making changes to `higher-priority apps <https://github.com/open-contracting/standard-maintenance-scripts/blob/master/badges.md>`__.

Private templates
-----------------

If in ``pillar/private`` or ``salt/private`` you add, remove or rename a file or variable (but not if you change the value of a variable), replicate the changes in ``pillar/private-templates`` and ``salt/private-templates``.
