Microsoft Azure
===============

Users
-----

1. Click the *Users* Azure service
1. Click the *New user* menu
1. Click the *Invite external user* menu item
1. Enter the email address in *Email*
1. Enter a display name in *Display name*, if desired
1. Click the *Assignments* tab
1. Click the *Add role* button
1. Check the *Global Administrator* role
1. Click the *Review + invite* button
1. Click the *Invite* button

Access control (IAM)
--------------------

-  `Assign a user as an administrator of an Azure subscription <https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal-subscription-admin>`__

Resource groups (RG)
--------------------

.. note::

   `Azure Network Watcher <https://learn.microsoft.com/en-us/azure/network-watcher/network-watcher-create?tabs=portal#disable-network-watcher-for-your-region>`__ is enabled by default and is managed by Azure. Resources are added to the "NetworkWatcherRG" resource group.

   `Azure Backup <https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-limitations/virtual-machines-move-limitations?tabs=azure-cli#virtual-machines-with-azure-backup>`__ automatically creates resource groups with the naming pattern ``AzureBackupRG_<VM location>_1``.
