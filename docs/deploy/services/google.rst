Google Workspace
================

Email
-----

Use `Google Postmaster Tools <https://postmaster.google.com/v2/sender_compliance?domain=open-contracting.org>`__ to `debug deliverability issues <https://support.google.com/mail/answer/9981691>`__ from AWS to Gmail.

These services send email from open-contracting.org:

-  `Gmail <https://support.google.com/a/topic/9202>`__
-  `Mailchimp <https://mailchimp.com/help/set-up-email-domain-authentication/>`__

These services send email from noreply.open-contracting.org:

-  :doc:`aws`

These services send email from payments.open-contracting.org:

-  `Trolley <https://support.trolley.com/s/article/How-to-set-up-White-Label-Emails>`__ (using `SendGrid <https://www.twilio.com/docs/sendgrid/ui/account-and-settings/how-to-set-up-domain-authentication>`__)

Servers send email from their FQDN, like ocp99.open-contracting.org.

Check DNS configuration
~~~~~~~~~~~~~~~~~~~~~~~

#. `Google Admin Toolbox Check MX <https://toolbox.googleapps.com/apps/checkmx/>`__ should report no problems (all green).
#. `MXToolBox Domain Health Report <https://mxtoolbox.com/emailhealth/>`__ should report no errors (only warnings).

.. _check-dmarc-compliance:

Check DMARC compliance
~~~~~~~~~~~~~~~~~~~~~~

Send an email to ping@tools.mxtoolbox.com and `check the results <https://mxtoolbox.com/deliverability>`__ (all green).

Similar tools include:

-  `Valimail Email Analyzer Report <https://app.valimail.com/app/open-contracting-partnership/dmarc/email_analyzer_reports>`_
-  `mail-tester <https://www.mail-tester.com>`__
-  `Postmark's Spam Check <https://spamcheck.postmarkapp.com>`__

.. _monitor-dmarc-reports:

Monitor DMARC reports
~~~~~~~~~~~~~~~~~~~~~

The `DMARC policies <https://support.google.com/a/answer/2466563>`__ send aggregate reports to:

-  `Cloudflare DMARC Management <https://developers.cloudflare.com/dmarc-management/>`__
-  Postmark's `DMARC Digests <https://dmarc.postmarkapp.com>`__
-  `Valimail Monitor <https://app.valimail.com>`__

.. code-block:: shell-session

   $ dig TXT _dmarc.open-contracting.org
   v=DMARC1; p=none; rua=mailto:re+tvgueigvygp@dmarc.postmarkapp.com,mailto:dmarc_agg@vali.email;

.. code-block:: shell-session

   $ dig TXT _dmarc.noreply.open-contracting.org
   v=DMARC1; p=none; rua=mailto:re+jbvvmcsfauo@dmarc.postmarkapp.com,mailto:dmarc_agg@vali.email;

.. code-block:: shell-session

   $ dig TXT _dmarc.open-spending.eu
   v=DMARC1; p=quarantine; rua=mailto:re+wtazrnx9nxe@dmarc.postmarkapp.com,mailto:dmarc_agg@vali.email;

.. code-block:: shell-session

   $ dig TXT dream-office.org
   v=DMARC1; p=none; rua=mailto:re+yjzbqifwsvu@dmarc.postmarkapp.com,mailto:dmarc_agg@vali.email;

DMARC compliance should be over 95%, and DKIM alignment should be over 90%. Failures should be 3% or less.

.. note::

   Mailchimp is `not SPF aligned <https://dmarc.io/source/mailchimp/>`__; therefore, we have no target for SPF alignment. It `sends mail from <https://mailchimp.com/help/my-campaign-from-name-shows-mcsvnet/>`__ ``mcsv.net``, ``mcdlv.net``, ``mailchimpapp.net`` and ``rsgsv.net``.

.. note::

   Tools might report a "DKIM invalid" warning due to AWS SES using `null DKIM records <https://repost.aws/questions/QUuPAl2F97RseJNexu2JP8CA/2-of-3-easy-dkim-ses-txt-records-where-p-tag-has-no-value-p>`__.

Sending domains with volumes of less than 10 can be ignored. For ``google.com``:

-  SPF misalignment with ``calendar-server.bounces.google.com`` `can be ignored <https://dmarcian.com/google-calendar-invites-dmarc/>`__.
-  Google Groups rewrites the ``From`` header `only if <https://support.dmarcdigests.com/article/1233-spf-or-dkim-alignment-issues-with-google>`__ the DMARC policy is "reject" or "quarantine".

..
   outbound.protection.outlook.com (Microsoft 365) https://learn.microsoft.com/en-us/microsoft-365/enterprise/external-domain-name-system-records
     Exchange Online
   lsoft.com
     UNCAC-COALITION@community.lsoft.com. LSOFT might rewrite the From header only if the DMARC policy is "reject" or "quarantine", like Google Groups.

Delete user
-----------

.. admonition:: One-time setup

   -  Install `Google Apps Manager (GAM) <https://github.com/GAM-team/GAM>`__. In a bash shell:

      .. code-block:: bash

         bash <(curl -s -S -L https://gam-shortn.appspot.com/gam-install)

      -  Select only these scopes (``gam oauth create``):

         -  *0) Calendar API*
         -  *32) Directory API - Groups*
         -  *39) Directory API - Users*

         ..
            Calendar API
              ``gam calendar CALENDAR showacl``, ``gam calendars CALENDAR transfer``
            Directory API - Groups
              ``gam print groups``, ``gam print group-members``, ``gam update group``
            Directory API - Users
              ``gam print users``, ``gam all users_na_ns``, ``gam update user``, ``gam delete user``, ``gam undelete user``

      -  Limit its `Domain-wide Delegation <https://admin.google.com/ac/owl/domainwidedelegation>`__ to the scopes used when impersonating users with ``gam user`` and ``gam all``:

         -  ``https://www.googleapis.com/auth/drive``
         -  ``https://www.googleapis.com/auth/calendar``

   -  Install `Got Your Back (GYB) <https://github.com/GAM-team/got-your-back>`__. In a bash shell:

      .. code-block:: bash

         bash <(curl -s -S -L https://gyb-shortn.jaylee.us/gyb-install)

Perform the global steps once, and repeat the other steps for each user to be deleted.

Setup (global)
~~~~~~~~~~~~~~

#. Configure the administrator, `OCP Archive <https://drive.google.com/drive/folders/0AKb5W5k2WH46Uk9PVA>`__ shared drive, and `GAM <https://github.com/GAM-team/GAM>`__ and `GYB <https://github.com/GAM-team/got-your-back>`__ service accounts:

   .. code-block:: bash

      set admin jmckinney
      set shareddrive 0AKb5W5k2WH46Uk9PVA
      set gamproject gam-project-9yro6
      set gybproject gyb-project-haj-zu2-x36

#. Enable the service accounts:

   .. code-block:: bash

      gcloud iam service-accounts enable $gamproject@$gamproject.iam.gserviceaccount.com --project $gamproject
      gcloud iam service-accounts enable $gybproject@$gybproject.iam.gserviceaccount.com --project $gybproject

#. Write the shortcuts in active users' *My Drive* and shared drives:

   .. code-block:: bash

      gam all users_na_ns print filelist corpora alldrives \
        query "mimeType='application/vnd.google-apps.shortcut' and not trashed" \
        fields id,name,owners,driveid,parents,shortcutdetails > google-shortcuts.csv

Calendar (global)
~~~~~~~~~~~~~~~~~

A secondary calendar is a calendar that a user creates in addition to their default calendar. It is deleted along with its creator, even if other users are owners.

To verify that no calendar in use by active users was created by an archived user, we review all active users' calendar lists, due to limitations of the Calendar API.

#. Write the calendar lists of active users:

   .. code-block:: bash

      gam all users_na_ns print calendars > google-calendars.csv

#. Report the secondary calendars that are owned by archived users:

   .. code-block:: bash

      uv run manage.py google-calendar google-calendars.csv

#. Transfer all reported calendars to an active user, before deleting the archived users.

Setup
~~~~~

Configure the user to delete and its retention start date. For example:

.. code-block:: bash

   set user data-tools
   set retentionstartdate 2026-08-08

.. _gmail:

Gmail
~~~~~

#. Unarchive the user:

   .. code-block:: bash

      gam update user $user@open-contracting.org archived off

#. Backup the user's mail:

   .. code-block:: bash

      gyb --email $user@open-contracting.org --service-account --action backup \
        --local-folder $user-$retentionstartdate --fast-incremental

   .. attention::

      If errors are logged, re-run the command to backup missed messages.

#. Compress the backup:

   .. code-block:: bash

      tar czf $user-$retentionstartdate-gmail.tar.gz $user-$retentionstartdate

#. Upload the backup to the *OCP Archive* shared drive:

   .. code-block:: bash

      gam user $admin@open-contracting.org add drivefile \
        localfile $user-$retentionstartdate-gmail.tar.gz teamdriveparentid $shareddrive

#. Delete the local files:

   .. code-block:: bash

      rm -rf $user-$retentionstartdate $user-$retentionstartdate-gmail.tar.gz

Groups
~~~~~~

#. List the groups of which the user is an owner, along with all owners:

   .. code-block:: bash

      gam print groups member $user@open-contracting.org role owner

#. If the user is the sole owner of a group, add another owner, replacing ``GROUP`` and ``USER``:

   .. code-block:: bash

      gam update group GROUP@open-contracting.org add owner USER@open-contracting.org

   .. note:: If the new owner is already a member or manager of the group, use ``update``, instead of ``add``.

.. _drive:

Drive
~~~~~

#. List the user's files in Drive:

   .. code-block:: bash

      gam user $user@open-contracting.org print filelist \
        query "not trashed" \
        showownedby me fields id,name,mimetype,modifiedtime > google-drive-$user.csv

#. List the user's Forms, Sites and Apps Script in Drive, whose deletion could break things:

   .. code-block:: bash

      gam user $user@open-contracting.org print filelist \
        showownedby me fields id,name,mimetype,modifiedtime \
        query "mimeType='application/vnd.google-apps.form' or mimeType='application/vnd.google-apps.site' or mimeType='application/vnd.google-apps.script'"

#. Report the user's files that have shortcuts:

   .. code-block:: bash

      uv run manage.py google-drive google-drive-$user.csv google-shortcuts.csv

   For each shared drive, it prints commands to run, in order to move those files next to the shortcuts in that shared drive, and to delete those shortcuts.

   If a folder has shortcuts from active users' *My Drive*, notify those users of the new folder (folders can't be moved, only recreated).

   Re-run step 1 (list the user's files), then re-run this step.

#. You may review the ``google-drive-$user.csv`` file, and move any other in-use files to shared drives. Replace ``FILE_ID``, and replace ``FOLDER_ID`` with a shared drive or one of its folders:

   .. code-block:: bash

      gam user $user@open-contracting.org move drivefile FILE_ID \
        shareddriveparentid FOLDER_ID duplicatefiles uniquename summary showpermissionmessages

   To move several, change ``FILE_ID`` to: ``ids FILE_ID_1,FILE_ID_2``

#. Move the remaining files to the *OCP Archive* shared drive:

   #. Make the user a *Manager* of the shared drive:

      .. code-block:: bash

         gam add drivefileacl $shareddrive user $user@open-contracting.org role manager

   #. Create a folder named after the user, and configure it as the destination:

      .. code-block:: bash

         set folder ( \
           gam user $admin@open-contracting.org create drivefile \
             shareddriveparentid $shareddrive mimetype gfolder \
             drivefilename $user-$retentionstartdate returnidonly \
         )

   #. Move the user's *My Drive* into the folder, preserving the hierarchy:

      .. code-block:: bash

         gam user $user@open-contracting.org move drivefile \
           root mergewithparentretain \
           shareddriveparentid $folder createshortcutsfornonmovablefiles \
           duplicatefiles uniquename summary showpermissionmessages

      .. attention::

         If you see this fragment, those files might be in use.

         .. code-block:: none

            is not a member of this shared drive

      .. note::

         -  Folders are recreated, and therefore change IDs.
         -  Files owned by other users are replaced by shortcuts.
         -  ``duplicatefiles uniquename`` renames files that have the same name as a file at the destination. Otherwise, the default is to delete the file in the destination, if it is older.

   #. Move remaining files (those in other users' folders or with no parent folder), *with no hierarchy*:

      .. code-block:: bash

         gam user $user@open-contracting.org move drivefile \
           query "'me' in owners and not trashed and mimeType != 'application/vnd.google-apps.folder'" \
           shareddriveparentid $folder duplicatefiles uniquename summary showpermissionmessages

   #. Confirm that no files remain:

      .. code-block:: bash

         gam user $user@open-contracting.org print filelist \
           query "'me' in owners and not trashed and mimeType != 'application/vnd.google-apps.folder'" \
           fields id,name,parents

   #. Remove the user from the shared drive:

      .. code-block:: bash

         gam delete drivefileacl $shareddrive $user@open-contracting.org

      .. note::

         Retry on 409 Conflict. Google might still be moving files.

Deletion
~~~~~~~~

#. Delete the user:

.. code-block:: bash

   gam delete user $user@open-contracting.org

.. tip::

   You can undelete within 20 days, replacing ``USER``:

   .. code-block:: bash

      gam undelete user USER@open-contracting.org

Teardown (global)
~~~~~~~~~~~~~~~~~

Disable the service accounts:

.. code-block:: bash

   gcloud iam service-accounts disable $gamproject@$gamproject.iam.gserviceaccount.com --project $gamproject
   gcloud iam service-accounts disable $gybproject@$gybproject.iam.gserviceaccount.com --project $gybproject

Delete temporary files:

.. code-block:: bash

   rm -f google-calendars.csv google-drive-*.csv google-shortcuts.csv

Orphaned files
--------------

An orphaned file has no parent folder, reachable only by search or shortcut.

A file is orphaned when the folder that contained it is moved to a shared drive by a user who doesn't own the file, in which case the folder is recreated in the shared drive with a shortcut to the file.

To review orphaned files, replacing ``USER``:

.. code-block:: bash

   gam user USER@open-contracting.org print filelist select orphans excludetrashed \
     fields id,name,mimetype,parents

.. note::

   If moving files, move only those whose ``parents.0.id`` is empty or isn't listed (i.e. the parent is outside your *My Drive*).
