DNS
===

DNS is hosted with `GoDaddy <https://sso.godaddy.com>`__.

Lock all domain names in the `Domain Portfolio <https://dcc.godaddy.com/control/portfolio>`__.

TTL standardisation
-------------------

The Time to Live (TTL) of a DNS record indicates how long DNS clients should cache the DNS record. Set the TTL as follows:

.. list-table::
   :header-rows: 1

   * - Purpose
     - Record type
     - TTL
   * - Hostname
     - A and AAAA
     - 1 day (86400 seconds)
   * - High availability service
     - CNAME
     - 5 min (300 seconds)
   * - Other
     - CNAME
     - 1 hour (3600 seconds)

Cloudflare
----------

Proxy status
~~~~~~~~~~~~

-  Proxy A, AAAA and CNAME records for web traffic to OCP servers.
-  Don't proxy A, AAAA or CNAME records for web traffic to third-party servers, like `GitHub Pages <https://github.com/orgs/community/discussions/22790>`__, `Netlify <https://answers.netlify.com/t/support-guide-why-not-proxy-to-netlify/8869>`__ or `Super <https://super.so/guides/using-super-with-cloudflare>`__.
-  Don't proxy A or AAAA records for hostnames, like ``ocp42``. (`Ports for SSH and non-web protocols are closed. <https://blog.cloudflare.com/cloudflare-now-supporting-more-ports/>`__)

Reference: `Cloudflare documentation <https://developers.cloudflare.com/dns/proxy-status/>`__

Reference
---------

.. seealso:: :ref:`monitor-dmarc-reports`

.. note:: ``MS=…`` TXT records For `Microsoft domain verification <https://learn.microsoft.com/en-us/microsoft-365/admin/get-help-with-domains/create-dns-records-at-any-dns-hosting-provider#recommended-verify-with-a-txt-record>`__ can be deleted.

This table is mostly relevant to open-contracting.org.

.. list-table::
   :header-rows: 1

   * - Type
     - Name
     - Value
     - Source
   * - MX
     - ``@``
     - ``aspmx.l.google.com`` name
     - `Google Workspace <https://support.google.com/a/answer/16004259?hl=en>`__
   * - MX
     - ``mail.noreply``
     - ``feedback-smtp.us-east-1.amazonses.com``
     - `Amazon SES <https://us-east-1.console.aws.amazon.com/ses/home?region=us-east-1#/identities/noreply%40noreply.open-contracting.org>`__ MAIL FROM
   * - MX
     - ``noreply``
     - ``inbound-smtp.us-east-1.amazonaws.com``
     - `Amazon SES <https://docs.aws.amazon.com/ses/latest/dg/receiving-email-mx-record.html>`__ receiving
   * - CNAME
     - Various
     - ``ocp##.open-contracting.org``
     - OCP
   * - CNAME
     - Various
     - ``pages.dev`` name
     - GitHub
   * - CNAME
     - Various
     - ``cname.super.so``
     - Super
   * - CNAME
     - ``…._domainkey.noreply``
     - ``dkim.amazonses.com`` name
     - `Amazon SES <https://us-east-1.console.aws.amazon.com/ses/home?region=us-east-1#/identities/noreply.open-contracting.org>`__ domain
   * - CNAME
     - ``cdn.credere``
     - ``cloudfront.net`` name
     - `AWS CloudFront <https://us-east-1.console.aws.amazon.com/cloudfront/v4/home?region=us-east-1#/distributions/E1NFC1BEGJ978N>`__
   * - CNAME
     - ``_….cdn.credere``
     - ``acm-validations.aws`` name
     - `AWS Certificate Manager <https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/a8b484c6-393a-41f5-82b4-e5c3c24ed008>`__
   * - CNAME
     - - ``k2._domainkey``
       - ``k3._domainkey``
     - ``mcsv.net`` name
     - `Mailchimp <https://mailchimp.com/help/set-up-email-domain-authentication/>`__
   * - CNAME
     - - ``payments``
       - ``pr._domainkey``
       - ``pr2._domainkey``
     - ``sendgrid.net`` name
     - `Trolley <https://support.trolley.com/s/article/How-to-set-up-White-Label-Emails>`__ (`SendGrid <https://www.twilio.com/docs/sendgrid/ui/account-and-settings/how-to-set-up-domain-authentication>`__)
   * - TXT
     - ``ocp##``
     - SPF policy
     - See :ref:`Create DNS records<create-dns-records>`
   * - TXT
     - ``@``
     - SPF policy
     - `Google Workspace <https://support.google.com/a/answer/33786?hl=en>`__
   * - TXT
     - ``google._domainkey``
     - DKIM key record
     - `Google Workspace <https://support.google.com/a/answer/174124?Hl=en>`__
   * - TXT
     - ``_dmarc``
     - DMARC policy
     - `Google Workspace <https://support.google.com/a/answer/2466580?hl=en>`__
   * - TXT
     - ``mail.noreply``
     - SPF policy
     - `Amazon SES <https://us-east-1.console.aws.amazon.com/ses/home?region=us-east-1#/identities/noreply%40noreply.open-contracting.org>`__ MAIL FROM
   * - TXT
     - ``_dmarc.noreply``
     - DMARC policy
     - `Amazon SES <https://us-east-1.console.aws.amazon.com/ses/home?region=us-east-1#/identities/noreply.open-contracting.org>`__ domain
   * - TXT
     - ``sign._domainkey``
     - DKIM key record
     - `SendPulse <https://sendpulse.com/knowledge-base/email-service/additional/email-authentication>`__
   * - TXT
     - ``_smtp._tls``
     - `SMTP TLS Reporting <https://datatracker.ietf.org/doc/html/rfc8460>`__ policy
     - `Valimail <https://support.valimail.com/en/articles/10707728-how-to-set-up-tls-reporting-and-mta-sts>`__
   * - TXT
     - ``_atproto``
     - `DID <https://atproto.com/specs/did>`__
     - `Bluesky <https://bsky.social/about/blog/4-28-2023-domain-handle-tutorial>`__
   * - TXT
     - ``@``
     - ``google-site-verification=…``
     - `Google Search Console <https://support.google.com/webmasters/answer/9008080?hl=en#:~:text=How%20long%20does%20verification%20last>`__ (per `user <https://search.google.com/search-console/users?resource_id=sc-domain%3Aopen-contracting.org>`__)
   * - TXT
     - ``@``
     - ``atlassian-domain-verification=…``
     - `Atlassian <https://support.atlassian.com/user-management/docs/verify-a-domain-to-manage-accounts/>`__
