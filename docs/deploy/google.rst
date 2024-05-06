Google Workspace
================

Email
-----

Use `Google Postmaster Tools <https://postmaster.google.com/managedomains>`__ to `debug deliverability issues <https://support.google.com/mail/answer/9981691>`__ from AWS to GMail.

These services send email from open-contracting.org:

-  :doc:`aws`
-  `Mailchimp <https://mailchimp.com/help/set-up-email-domain-authentication/>`__
-  `Salesforce <https://help.salesforce.com/s/articleView?id=000354353&language=en_US&type=1>`__: `SPF <https://help.salesforce.com/s/articleView?language=en_US&id=sf.emailadmin_spf_include_salesforce.htm&type=5>`__ and `DKIM <https://help.salesforce.com/s/articleView?language=en_US&id=sf.emailadmin_create_secure_dkim.htm&type=5>`__

These services send email from noreply.open-contracting.org:

-  :doc:`aws`

These services send email from payments.open-contracting.org:

-  `Trolley <https://support.trolley.com/s/article/How-to-set-up-White-Label-Emails>`__ (using `SendGrid <https://docs.sendgrid.com/ui/account-and-settings/how-to-set-up-domain-authentication>`__)

Check DNS configuration
~~~~~~~~~~~~~~~~~~~~~~~

#. `Google Admin Toolbox Check MX <https://toolbox.googleapps.com/apps/checkmx/>`__ should report no problems (all green).
#. `MXToolBox Domain Health Report <https://mxtoolbox.com/emailhealth/>`__ should report no errors (only warnings).

.. _check-dmarc-compliance:

Check DMARC compliance
~~~~~~~~~~~~~~~~~~~~~~

Send an email to ping@tools.mxtoolbox.com and `check the results <https://mxtoolbox.com/deliverability>`__ (all green).

Similar tools include `mail-tester <https://www.mail-tester.com>`__ and `Postmark's Spam Check <https://spamcheck.postmarkapp.com>`__.

Monitor DMARC reports
~~~~~~~~~~~~~~~~~~~~~

open-contracting.org's `DMARC policy <https://support.google.com/a/answer/2466563>`__ sends aggregate and forensic reports to `DMARC Analyzer <https://app.dmarcanalyzer.com/>`__ (defaults to reporting today only):

.. code-block:: shell-session

   $ dig TXT _dmarc.open-contracting.org
   v=DMARC1; p=none; fo=1; rua=mailto:re+tvgueigvygp@dmarc.postmarkapp.com,mailto:e57de3ae23df489@rep.dmarcanalyzer.com; ruf=mailto:e57de3ae23df489@for.dmarcanalyzer.com;

.. code-block:: shell-session

   $ dig TXT _dmarc.noreply.open-contracting.org
   v=DMARC1; p=none; fo=1; rua=mailto:e57de3ae23df489@rep.dmarcanalyzer.com; ruf=mailto:e57de3ae23df489@for.dmarcanalyzer.com;

DMARC compliance should be over 95%, and DKIM alignment should be over 90%. Failures should be 3% or less.

.. note::

   Mailchimp is `not SPF aligned <https://dmarc.io/source/mailchimp/>`__; therefore, we have no target for SPF alignment. It `sends mail from <https://mailchimp.com/help/my-campaign-from-name-shows-mcsvnet/>`__ ``mcsv.net``, ``mcdlv.net``, ``mailchimpapp.net`` and ``rsgsv.net``.

When filtering per result, sending domains with volumes of less than 10 can be ignored. For ``google.com``:

-  SPF misalignment with ``calendar-server.bounces.google.com`` `can be ignored <https://dmarcian.com/google-calendar-invites-dmarc/>`__.
-  Google Groups rewrites the ``From`` header `only if <https://support.dmarcdigests.com/article/1233-spf-or-dkim-alignment-issues-with-google>`__ the DMARC policy is "reject" or "quarantine".

..
   secureserver.net (GoDaddy) https://ca.godaddy.com/help/add-an-spf-record-19218
     Professional Email, Microsoft 365 from GoDaddy, Linux Hosting, Gen 4 VPS & Dedicated Hosting, and Media Temple Mail
   outbound.protection.outlook.com (Microsoft 365) https://learn.microsoft.com/en-us/microsoft-365/enterprise/external-domain-name-system-records
     Exchange Online
   lsoft.com
     UNCAC-COALITION@community.lsoft.com. LSOFT might rewrite the From header only if the DMARC policy is "reject" or "quarantine", like Google Groups.
