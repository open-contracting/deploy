Making changes
==============

Salt changes - Testing against a virtual machine or making changes against live servers
---------------------------------------------------------------------------------------

In other code repositories, we require work to be done in a branch and tested on local machines before a pull request is made. Approval is needed before merging.

Sometimes, it is possible to test changes to these scripts against a virtual machine and in a separate branch.

Sometimes it's not possible to test against a virtual machine. Cases like this include when SSL certificates are involved (as certbot can not verify the virtual machine) or when external services like Travis are involved.
Sometimes, for small changes the amount of time it would take to set up a full test environment is not worth it.

In these cases, people work on the `master` branch, deploy directly to live machines and commit straight to the `master` branch afterwards.

When deploying in this way, extra care should be taken. If worried, seek another staff members review before proceeding.

For this reason, the `master` branch is not protected.

TODO Discuss this. Discuss procedures for people who can not deploy for whatever reason to make changes (eg always via pull request?).
Have clearer guidelines about when it is and is not appropriated to commit straight to master. Document.

Update private templates
------------------------

If you add a new variable or file to `pillar/private` and `salt/private`, or you remove something, or you rename something,
you must make sure the template files in `pillar/private-templates` and `salt/private-templates` are updated at the same time.

If you only change the contents of one of those variables or files, you do not need to change `private-templates`.

Changes to non-salt resources (eg. scripts used by Travis)
----------------------------------------------------------

TODO Discuss procedures and document such that all staff can make changes to these.
