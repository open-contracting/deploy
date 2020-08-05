Amazon Web Services (AWS)
=========================

Simple Email Service (SES)
--------------------------

Reference: `Setting up Email with Amazon SES <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-set-up.html>`__

Verify a domain
~~~~~~~~~~~~~~~

#. Go to SES' `Domains <https://console.aws.amazon.com/ses/home?region=us-east-1#verified-senders-domain:>`__:

   #. Click *Verify a New Domain*
   #. Enter the domain in *Domain:*
   #. Check the *Generate DKIM Settings* box
   #. Click *Verify This Domain*

#. Go to GoDaddy's `DNS Management <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__:

   #. Add the TXT and CNAME records. Add the MX record if none exists.

      .. note::

         SES' *DKIM Record Set* is a scrollable table with three records.

      .. note::

         Omit ``.open-contracting.org`` from hostnames. GoDaddy appends it automatically.

   #. `Add or update the SPF record <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/send-email-authentication-spf.html>`__

#. Wait for the domain's verification status to become "verified" on SES' `Domains <https://console.aws.amazon.com/ses/home?region=us-east-1#verified-senders-domain:>`__

   .. note::

      AWS will notify you by email. Last time, it took a few minutes.

Reference: `Verifying a Domain <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-domain-procedure.html>`__

Verify an email address
~~~~~~~~~~~~~~~~~~~~~~~

#. Check that the domain's verification status is "verified" on SES' `Domains <https://console.aws.amazon.com/ses/home?region=us-east-1#verified-senders-domain:>`__

#. If an MX record didn't exist, go to SES' `Rule Sets <https://console.aws.amazon.com/ses/home?region=us-east-1#receipt-rules:>`__:

   #. Click *Create a New Rule Set*
   #. Click the rule set's name
   #. Click *Create Rule*
   #. Click *Next Step*
   #. Select "S3" from the *Add action* dropdown
   #. Select "Create S3 bucket" from the *S3 bucket* dropdown
   #. Enter a bucket name in *Bucket Name*
   #. Click *Create Bucket*
   #. Click *Next Step*
   #. Enter a rule name in *Rule Name*
   #. Click *Next Step*
   #. Click *Create Rule*
   #. Go to SES' `Rule Sets <https://console.aws.amazon.com/ses/home?region=us-east-1#receipt-rules:>`__
   #. Check the rule set's box
   #. Click *Set as Active Rule Set*

#. Go to SES' `Email Addresses <https://console.aws.amazon.com/ses/home?region=us-east-1#receipt-rules:>`__:

   #. Click *Verify a New Email Address*
   #. Enter the email address in *Email Address:*
   #. Click *Verify This Email Address*

#. If an MX record didn't exist, go to `S3 <https://s3.console.aws.amazon.com/s3/home?region=us-east-1#>`__ (otherwise, check your email):

   #. Click the bucket name
   #. Click the long alpha-numeric string (if there is none, double-check the earlier steps)
   #. Click *Download*
   #. Copy the URL in the downloaded file
   #. Open the URL in a web browser

#. Check that the email address's verification status is "verified" on SES' `Email Addresses <https://console.aws.amazon.com/ses/home?region=us-east-1#receipt-rules:>`__

#. If an MX record didn't exist, cleanup:

   #. Delete the bucket
   #. Disable and delete the rule set
   #. Remove the MX record

Reference: `Verifying an Email Address <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/verify-email-addresses-procedure.html>`__

Create SMTP credentials
~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   You only need to do this once per AWS region.

#. Go to SES' `SMTP Settings <https://console.aws.amazon.com/ses/home?region=us-east-1#smtp-settings:>`__

   #. Click *Create My SMTP Credentials*
   #. Enter a user name in *IAM User Name:*
   #. Click *Create*
   #. Click *Download Credentials*
   #. Click *Close*

Reference: `Getting Your SMTP Credentials <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/get-smtp-credentials.html>`__

Move out of sandbox
~~~~~~~~~~~~~~~~~~~

.. note::

   You only need to do this once per AWS account.

Reference: `Moving Out of the Amazon SES Sandbox <https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html>`__

Aurora Serverless
-----------------

Adjust this template as needed:

1. Choose a database creation method: (no changes)
1. Engine options

   1. *Engine type*: Amazon Aurora
   1. *Edition*: Amazon Aurora with PostgreSQL compatibility
   1. *Version*: Aurora PostgreSQL (compatible with PostgreSQL 10.7)

1. Database features: Serverless
1. Settings: (no changes)
1. Capacity settings

   1. *Minimum Aurora capacity unit*: 2
   1. *Maximum Aurora capacity unit*: 2
   1. Expand *Additional scaling configuration*
   1. Check *Pause compute capacity after consecutive minutes of inactivity*
   1. Set to *1* hours 0 minutes 0 seconds

1. Connectivity

   1. *Virtual private cloud (VPC)*: Select a VPC that is configured to be `publicly accessible <https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.CreateDBInstanceInVPC>`__
   1. *VPC security group*: Create new

1. Additional configuration

   1. *Initial database name*: common
   1. *Backup retention period*: 1 day

1. Click *Create database*
