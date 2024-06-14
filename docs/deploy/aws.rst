Amazon Web Services (AWS)
=========================

Our default region is *us-east-1* (N. Virginia). For large data transfer operations (like backups), use the closest region: for example, *us-west-2* (London) for Linode servers in the London datacenter.

Simple Email Service (SES)
--------------------------

Reference: `Setting up Amazon Simple Email Service <https://docs.aws.amazon.com/ses/latest/dg/setting-up.html>`__

.. note::

   `Dedicated IP addresses for Amazon SES <https://docs.aws.amazon.com/ses/latest/dg/dedicated-ip.html>`__ are available. However, a dedicated IP address would take a long time to cultivate a sending reputation with our low volume. The shared IP addresses have good reputation. As describe below, SPF, DKIM and Return-Path are configured to improve deliverability.

Verify a domain
~~~~~~~~~~~~~~~

#. Go to SES' `Verified identities <https://us-east-1.console.aws.amazon.com/ses/home#/verified-identities>`__:

   #. Click *Create identity*
   #. Check *Domain*
   #. Enter the domain in *Domain*
   #. Expand *Advanced DKIM settings*
   #. Check *Easy DKIM*
   #. Check *RSA_2048_BIT*
   #. Click *Create identity*

#. Go to GoDaddy's `DNS Management <https://dcc.godaddy.com/manage/OPEN-CONTRACTING.ORG/dns>`__:

   #. Add the three CNAME records. Add the MX record if none exists.

      .. note::

         Omit ``.open-contracting.org`` from hostnames. GoDaddy appends it automatically.

   #. `Add or update the SPF record <https://docs.aws.amazon.com/ses/latest/dg/send-email-authentication-spf.html>`__

#. Wait for the domain's *Identity status* to become "Verified" on SES' `Verified identities <https://us-east-1.console.aws.amazon.com/ses/home#/verified-identities>`__

   .. note::

      AWS will notify you by email. Last time, it took a few minutes.

Reference: `Creating (and verifying) a domain identity <https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-domain-procedure>`__

Verify an email address
~~~~~~~~~~~~~~~~~~~~~~~

#. Go to SES' `Verified identities <https://us-east-1.console.aws.amazon.com/ses/home#/verified-identities>`__:

   #. Click *Create identity*
   #. Check *Email address*
   #. Enter the email address in *Email address*
   #. Click *Create identity*

#. If the domain's MX record points to AWS, go to SES' `Email receiving <https://us-east-1.console.aws.amazon.com/ses/home#/email-receiving>`__:

   #. Click *Create rule set*
   #. Enter a name in *Rule set name* (``email-address-verification``, for example)
   #. Click *Create rule set*
   #. Click the rule set's name
   #. Click *Create rule*
   #. Enter a rule name in *Rule name* (``deliver-to-s3-bucket``, for example)
   #. Click *Next*
   #. Click *Next*
   #. Select "Deliver to S3 bucket" from the *Add new action* dropdown
   #. Click *Create S3 bucket*
   #. Enter a bucket name in *Bucket name* (``ocp-aws-verification``, for example)
   #. Click *Create bucket*
   #. Click *Next*
   #. Click *Create rule*
   #. Click *Set as active*

#. If the domain's MX record points to AWS, go to `S3 <https://us-east-1.console.aws.amazon.com/s3/buckets?region=us-east-1>`__ (otherwise, check your email):

   #. Click the bucket name
   #. Click the long alphanumeric string (if there is none, double-check the earlier steps)
   #. Click *Download*
   #. Copy the URL in the downloaded file
   #. Open the URL in a web browser

#. Check that the email address' *Identity status* is "Verified" on SES' `Verified identities <https://us-east-1.console.aws.amazon.com/ses/home#/verified-identities>`__

#. If the domain's MX record points to AWS, cleanup:

   #. Set the rule set as inactive

Reference: `Creating (and verifying) an email address identity <https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html#verify-email-addresses-procedure>`__

Use a MAIL FROM domain
~~~~~~~~~~~~~~~~~~~~~~

.. note::

   This optional step improves email deliverability. Also known as the Return-Path address.

#. Refer to `Using a custom MAIL FROM domain <https://docs.aws.amazon.com/ses/latest/dg/mail-from.html#mail-from-set>`__
#. Check that the verified identity's *MAIL FROM configuration* is "Successful"

Create SMTP credentials
~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   You only need to do this once per AWS region.

#. Go to SES' `SMTP Settings <https://us-east-1.console.aws.amazon.com/ses/home#smtp>`__:

   #. Click *Create SMTP credentials*
   #. Enter a user name in *IAM User Name:*
   #. Click *Create*
   #. Click *Download Credentials*
   #. Click *Close*

Reference: `Obtaining Amazon SES SMTP credentials <https://docs.aws.amazon.com/ses/latest/dg/smtp-credentials.html>`__

.. _ses-basic-notifications:

Set up basic notifications
~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Go to SNS' `Topics <https://us-east-1.console.aws.amazon.com/sns/v3/home#/topics>`__:

   #. Click *Create topic*
   #. Set *Type* to *Standard*
   #. Enter a hyphenated address in *Name* (``data-open-contracting-org``, for example)
   #. Click *Create topic*

#. Click *Create subscription*:

   #. Select "Email" from the *Protocol* dropdown
   #. Enter an email address in *Endpoint*
   #. Click *Create subscription*

#. Click the email address on SES' `Verified identities <https://us-east-1.console.aws.amazon.com/ses/home#/verified-identities>`__:

   #. Click the *Notifications* tab
   #. Click *Edit* in the *Feedback notifications* section
   #. Select the created topic from the *Bounce feedback* dropdown
   #. Check the *Include original email headers* box
   #. Select the created topic from the *Complaint feedback* dropdown
   #. Check the *Include original email headers* box
   #. Click *Save changes*

Reference: `Configuring Amazon SNS notifications for Amazon SES <https://docs.aws.amazon.com/ses/latest/dg/configure-sns-notifications.html>`__

Set up advanced notifications
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#. Go to SES' `Configuration sets <https://us-east-1.console.aws.amazon.com/ses/home#/configuration-sets>`__:

   #. Click *Create set*
   #. Enter a name in *Configuration set name* (``credere``, for example)
   #. Click *Create set*

#. Click the configuration set's name
#. Click the *Event destinations* tab
#. Click *Add destination*:

   #. Check:

      -  Rendering failures, if using email templates
      -  Rejects
      -  Delivery delays

      Do not check, to avoid unnecessary notifications:

      -  Sends
      -  Deliveries (same as *Delivery feedback* above)
      -  Hard bounces (same as *Bounce feedback* above)
      -  Complaints (same as *Complaint feedback* above)
      -  Subscriptions

   #. Click *Next*
   #. Check *Amazon SES*
   #. Enter a name in *Name* (``credere-noreply-open-contracting-org``, for example)
   #. Select the SNS topic for :ref:`basic notifications<ses-basic-notifications>` from the *SNS topic* dropdown
   #. Click *Next*
   #. Click *Add destination*

#. Go to SNS' `Subscriptions <https://us-east-1.console.aws.amazon.com/sns/v3/home#/subscriptions>`__:

   #. Click *Create subscription*
   #. Select the SNS topic from the *Topic ARN* dropdown
   #. Select "Email" from the *Protocol* dropdown
   #. Enter the subscriber's email address in *Endpoint*
   #. Click *Create subscription*

#. Wait for the email to confirm the subscription

Check DMARC compliance
~~~~~~~~~~~~~~~~~~~~~~

:ref:`check-dmarc-compliance`, sending the email using SES.

.. note::

   `SES adds an extra DKIM signature <https://docs.aws.amazon.com/ses/latest/dg/troubleshoot-dkim.html>`__ ("The extra DKIM signature, which contains ``d=amazonses.com``, is automatically added by Amazon SES. You can ignore it"). It is not aligned, but according to `RFC 7489 <https://datatracker.ietf.org/doc/html/rfc7489#page-10>`__, "a single email can contain multiple DKIM signatures, and it is considered to be a DMARC 'pass' if any DKIM signature is aligned and verifies."

Debug delivery issues
~~~~~~~~~~~~~~~~~~~~~

Bounces and complaints are sent to the subscribed address. The relevant properties of the notification message are:

-  `complaintSubType <https://docs.aws.amazon.com/ses/latest/dg/notification-contents.html#complaint-object>`__

-  `bounceType and bounceSubType <https://docs.aws.amazon.com/ses/latest/dg/notification-contents.html#bounce-types>`__
-  `diagnosticCode <https://docs.aws.amazon.com/ses/latest/dg/notification-contents.html#bounced-recipients>`__

.. seealso::

   -  `Viewing a list of addresses that are on the account-level suppression list <https://docs.aws.amazon.com/ses/latest/dg/sending-email-suppression-list.html#sending-email-suppression-list-view-entries>`__
   -  `Removing individual email addresses from your Amazon SES account-level suppression list <https://docs.aws.amazon.com/ses/latest/dg/sending-email-suppression-list.html#sending-email-suppression-list-manual-delete>`__
   -  `DNS Blackhole List (DNSBL) FAQs <https://docs.aws.amazon.com/ses/latest/dg/faqs-dnsbls.html>`__

Disable account-level suppression list
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   This optional step can negatively affect sender reputation.

Reference: `Disabling the account-level suppression list <https://docs.aws.amazon.com/ses/latest/dg/sending-email-suppression-list.html#sending-email-suppression-list-disabling>`__

Move out of sandbox
~~~~~~~~~~~~~~~~~~~

.. note::

   You only need to do this once per AWS account.

Reference: `Moving out of the Amazon SES sandbox <https://docs.aws.amazon.com/ses/latest/dg/request-production-access.html>`__

Relational Database Service (RDS)
---------------------------------

.. note::

   This configuration is for data analysis, where it is acceptable for the data to be lost.

#. Go to RDS' `Databases <https://us-east-1.console.aws.amazon.com/rds/home#databases:>`__
#. Click *Create database*

   #. Set *Engine type* to "PostgreSQL"
   #. Set *Version* to the latest version
   #. Set *Templates* to "Free tier"
   #. Check *Auto generate a password*
   #. Set *DB instance class* to "db.t3.micro"
   #. Uncheck *Enable storage autoscaling*
   #. Set *Public access* to "Yes"
   #. Add "postgresql-anywhere" to *Existing VPC security groups*
   #. Remove "default" from *Existing VPC security groups*
   #. Expand *Additional configuration*
   #. Uncheck *Enable automated backups*
   #. Uncheck *Enable encryption*
   #. Uncheck *Turn on Performance Insights*
   #. Click *Create database*

#. Wait for the database to be created
#. Click *View connection details*

.. Aurora Serverless is commented out, as not used.

   Aurora Serverless
   -----------------

   .. warning::

      `"You can't give an Aurora Serverless DB cluster a public IP address." <https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.html#aurora-serverless.limitations>`__. Instead, you need to use an EC2 instance as a bastion host.

   Create a VPC
   ~~~~~~~~~~~~

   #. Set *IPv4 CIDR block* to "10.0.0.0/16"
   #. Click *Create*

   Reference: `Create a DB instance in the VPC <https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_VPC.WorkingWithRDSInstanceinaVPC.html#USER_VPC.CreateDBInstanceInVPC>`__

   Create subnets
   ~~~~~~~~~~~~~~

   #. Set *VPC* to the created VPC
   #. Set *Availability Zone* to any zone
   #. Set *IPv4 CIDR block* to "10.0.1.0/24"
   #. Click *Create*

   Then:

   #. Set *VPC* to the created VPC
   #. Set *Availability Zone* to another zone
   #. Set *IPv4 CIDR block* to "10.0.2.0/24"
   #. Click *Create*

   Create security group
   ~~~~~~~~~~~~~~~~~~~~~

   #. Set *Security group name* to "postgresql-anywhere"
   #. Set *Description* to "Allows PostgreSQL connections from anywhere"
   #. Click *Add rule* under *Inbound rules*
   #. Set *Type* to "PostgreSQL"
   #. Set *Source* to "Anywhere"
   #. Click *Create security group*

   Create database
   ~~~~~~~~~~~~~~~

   #. Choose a database creation method: (no changes)
   #. Engine options

      #. *Engine type*: Amazon Aurora
      #. *Edition*: Amazon Aurora with PostgreSQL compatibility
      #. *Version*: Aurora PostgreSQL (compatible with PostgreSQL 10.7)

   #. Database features: Serverless
   #. Settings: (no changes)
   #. Capacity settings

      #. *Minimum Aurora capacity unit*: 2
      #. *Maximum Aurora capacity unit*: 2
      #. Expand *Additional scaling configuration*
      #. Check *Pause compute capacity after consecutive minutes of inactivity*
      #. Set to *1* hours 0 minutes 0 seconds

   #. Connectivity

      #. *Virtual private cloud (VPC)*: Select the created VPC
      #. Expand *Additional connectivity configuration*
      #. *VPC security group*:

         #. Select the created group
         #. Remove the default group

      #. Check *Data API*

   #. Additional configuration

      #. *Initial database name*: common
      #. *Backup retention period*: 1 day

   #. Click *Create database*

Amazon S3
---------

.. _aws-s3-bucket:

Create bucket
~~~~~~~~~~~~~


#. Go to Amazon S3 `Buckets <https://us-east-1.console.aws.amazon.com/s3/buckets?region=us-east-1>`__
#. Select the nearest region to the server from the top-right dropdown
#. Click the *Create bucket* button

   #. Enter a *Bucket name* (``ocp-redmine-backup``, for example)
   #. Click the *Create bucket* button

If the bucket is for :doc:`file<../develop/update/backup>` or :ref:`MySQL<mysql-backups>` backups:

.. warning::

   Do **not** create lifecycle rules when using :ref:`pgBackRest<pg-setup-backups>`, which manages lifecycle itself.

#. Click the created bucket
#. Click the *Management* tab
#. Click the *Create lifecycle rule* button

   #. *Lifecycle rule name*: ``delete-after-30-days``
   #. *Choose a rule scope*: *Apply to all objects in the bucket*
   #. Check *I acknowledge that this rule will apply to all objects in the bucket.*
   #. Check *Expire current versions of objects*
   #. Check *Delete expired object delete markers or incomplete multipart uploads*
   #. *Days after object creation*: 30
   #. Check *Delete incomplete multipart uploads*
   #. *Number of days*: 7

#. Click *Create rule*

Reference: `Creating a bucket <https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html>`__

Identity and Access Management (IAM)
------------------------------------

.. _aws-iam-backup-policy:

Create a backup policy
~~~~~~~~~~~~~~~~~~~~~~

#. Go to IAM `Policies <https://us-east-1.console.aws.amazon.com/iamv2/home#/policies>`__
#. Click *Create policy*

   #. Click the *JSON* tab
   #. Paste the appropriate content below, replacing ``BUCKET_NAME`` and/or ``PREFIX``:

      pgBackRest backups
        .. code-block:: json

           {
               "Version": "2012-10-17",
               "Statement": [
                   {
                       "Effect": "Allow",
                       "Action": [
                           "s3:ListBucket"
                       ],
                       "Resource": [
                           "arn:aws:s3:::BUCKET_NAME"
                       ],
                       "Condition": {
                           "StringEquals": {
                               "s3:prefix": [
                                   "",
                                   "PREFIX"
                               ],
                               "s3:delimiter": [
                                   "/"
                               ]
                           }
                       }
                   },
                   {
                       "Effect": "Allow",
                       "Action": [
                           "s3:ListBucket"
                       ],
                       "Resource": [
                           "arn:aws:s3:::BUCKET_NAME"
                       ],
                       "Condition": {
                           "StringLike": {
                               "s3:prefix": [
                                   "PREFIX/*"
                               ]
                           }
                       }
                   },
                   {
                       "Effect": "Allow",
                       "Action": [
                           "s3:PutObject",
                           "s3:GetObject",
                           "s3:DeleteObject"
                       ],
                       "Resource": [
                           "arn:aws:s3:::BUCKET_NAME/PREFIX/*"
                       ]
                   }
               ]
           }

        .. seealso::

           `pgBackRest sample Amazon S3 policy <https://pgbackrest.org/user-guide.html#s3-support>`__
      File and MySQL backups
        .. code-block:: json

           {
               "Version": "2012-10-17",
               "Statement": [
                   {
                       "Effect": "Allow",
                       "Action": [
                           "s3:ListBucket"
                       ],
                       "Resource": [
                           "arn:aws:s3:::BUCKET_NAME"
                       ]
                   },
                   {
                       "Effect": "Allow",
                       "Action": [
                           "s3:PutObject",
                           "s3:GetObject",
                           "s3:DeleteObject"
                       ],
                       "Resource": [
                           "arn:aws:s3:::BUCKET_NAME/*"
                       ]
                   }
               ]
           }

   #. Click the *Next* button
   #. Enter a *Policy name* (``redmine-backup``, for example)
   #. Click the *Create policy* button

Create a backup user
~~~~~~~~~~~~~~~~~~~~

.. note::

   If a policy is relevant to many users, instead of attaching policies directly, create a group, attach the policy to the group, and add the user to the group.

#. Go to IAM `Users <https://us-east-1.console.aws.amazon.com/iamv2/home#/users>`__
#. Click the *Create user* button

   #. Enter a *User name* (``redmine-backup``, for example)#z
   #. Click the *Next* button
   #. Click the *Attach existing policies directly* radio button

   #. Search for and check the policy above
   #. Click the *Next* button
   #. Click the *Create user* button

#. Click the created user
#. Click the *Security credentials* tab
#. Click the *Create access key* button

   #. Check the *Command Line Interface (CLI)* radio button
   #. Check the *I understand the above recommendation and want to proceed to create an access key.* box
   #. Click the *Next* button
   #. Click the *Create access key* button
   #. Copy the *Access key* and *Secret access key*
   #. Click the *Done* button

Reference: `Creating an IAM user in your AWS account <https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html>`__
