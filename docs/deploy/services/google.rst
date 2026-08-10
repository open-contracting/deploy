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

#. Configure the user to delete and retention start date, for example:

   .. code-block:: bash

      set user data-tools
      set retentionstartdate 2026-08-08

Calendar
~~~~~~~~

A secondary calendar is a calendar that a user creates in addition to their default calendar. It is deleted along with its creator, even if other users are owners.

To verify that no calendar in use by active users was created by an archived user, we review all active users' calendar lists, due to limitations of the Calendar API.

#. Write the active users' calendar lists (slow):

   .. code-block:: bash

      gam all users_na_ns print calendars > google-calendars.csv

#. Report the secondary calendars that are owned by archived users:

   .. code-block:: bash

      uv run manage.py google-calendar google-calendars.csv

#. Transfer all reported calendars to an active user, before deleting the archived users.

Groups
~~~~~~

#. List the groups of which the user is an owner:

   .. code-block:: bash

      gam print groups member $user@open-contracting.org role owner

#. List the owners of each group, replacing ``GROUP``:

   .. code-block:: bash

      gam print group-members group GROUP@open-contracting.org role owner

#. If the user is the sole owner of a group, add another owner, replacing ``GROUP`` and ``USER``:

   .. code-block:: bash

      gam update group GROUP@open-contracting.org add owner USER@open-contracting.org

   If the new owner is already a member or manager of the group, use ``update``, instead of ``add``.

Drive
~~~~~

#. List the user's files in Drive:

   .. code-block:: bash

      gam user $user@open-contracting.org \
        print filelist showownedby me fields id,name,mimetype,modifiedtime > google-drive.csv

#. List the user's Forms, Sites and Apps Script in Drive, whose deletion is more likely to break things:

   .. code-block:: bash

      gam user $user@open-contracting.org \
        print filelist showownedby me fields id,name,mimetype,modifiedtime \
        query "mimeType='application/vnd.google-apps.form' or mimeType='application/vnd.google-apps.site' or mimeType='application/vnd.google-apps.script'"

#. Review the ``google-drive.csv`` file, and move actively used files to appropriate shared drives.

#. Move the remaining files to the *OCP Archive* shared drive:

   #. Configure the administrator, for example:

      .. code-block:: bash

         set admin jmckinney

   #. Configure the destination as the *OCP Archive* shared drive:

      .. code-block:: bash

         set shareddrive 0AKb5W5k2WH46Uk9PVA

   #. Make the user an organizer of the shared drive, which is required to move their files:

      .. code-block:: bash

         gam add drivefileacl $shareddrive user $user@open-contracting.org role organizer

   #. Create a folder named after the user, and configure it as the destination:

      .. code-block:: bash

         set folder ( \
           gam user $admin@open-contracting.org create drivefile drivefilename "$user-$retentionstartdate" \
             mimetype gfolder shareddriveparentid $shareddrive returnidonly \
         )

   #. Move the user's *My Drive* into the folder:

      .. code-block:: bash

         gam user $user@open-contracting.org move drivefile root \
           shareddriveparentid $folder mergewithparentretain createshortcutsfornonmovablefiles \
           duplicatefiles uniquename summary showpermissionmessages

      .. note::

         -  Folders are recreated, and therefore change IDs.
         -  Files owned by other users are replaced by shortcuts.
         -  ``duplicatefiles uniquename`` renames files that have the same name as a file in the destination. Otherwise, the default is to delete the file in the destination, if it is older.

   #. Move the files that remain. *My Drive* contains only the files that have a parent folder; the rest are in other users' folders, or have no parent folder. Run this after the previous step, which preserves the folder hierarchy: this moves every file that the user still owns, into one folder.

      .. code-block:: bash

         gam user $user@open-contracting.org move drivefile \
           query "'me' in owners and not trashed" \
           shareddriveparentid $folder createshortcutsfornonmovablefiles \
           duplicatefiles uniquename summary showpermissionmessages

   #. Confirm that no files remain:

      .. code-block:: bash

         gam user $user@open-contracting.org \
           print filelist showownedby me fields id,name,parents

   #. Remove the user from the shared drive:

      .. code-block:: bash

         gam delete drivefileacl $shareddrive $user@open-contracting.org

Deletion
~~~~~~~~

.. code-block:: bash

   gam delete user $user@open-contracting.org
