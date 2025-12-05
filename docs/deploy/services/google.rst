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

Servers send email from their FQDN, like ocp42.open-contracting.org.

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
   secureserver.net (GoDaddy) https://ca.godaddy.com/help/add-an-spf-record-19218
     Professional Email, Microsoft 365 from GoDaddy, Linux Hosting, Gen 4 VPS & Dedicated Hosting, and Media Temple Mail
   outbound.protection.outlook.com (Microsoft 365) https://learn.microsoft.com/en-us/microsoft-365/enterprise/external-domain-name-system-records
     Exchange Online
   lsoft.com
     UNCAC-COALITION@community.lsoft.com. LSOFT might rewrite the From header only if the DMARC policy is "reject" or "quarantine", like Google Groups.
