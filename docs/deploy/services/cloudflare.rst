Cloudflare
==========

Maintenance
-----------

Create an `account API token <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/api-tokens>`__ using the *Read all resources* template that includes *All zones from an account*, and set the ``CLOUDFLARE_API_TOKEN`` environment variable.

To compare zones' resources, run:

.. code-block:: bash

   uv run manage.py cloudflare zones -a ACCOUNT_ID

To review account-level resources, run:

.. code-block:: bash

   uv run manage.py cloudflare account -a ACCOUNT_ID > cloudflare-account.txt

To confirm that no other resources are used, run:

.. code-block:: bash

   uv run manage.py cloudflare unused -a ACCOUNT_ID

.. admonition:: Limitations

   The Terraform `Cloudflare Provider <https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs>`__ doesn't support at least:

   -  DMarc Management
   -  Page Shield (`API client <https://github.com/cloudflare/cloudflare-python/blob/main/api.md#pageshield>`__)

   Cloudflare-managed rulesets are omitted:

   -  ``ddos_l7``
   -  ``http_request_firewall_managed``
   -  ``http_request_sanitize``

Zone-level
----------

.. _dns:

DNS
~~~

.. _dns-ttl:

TTL
^^^

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

Proxy status
^^^^^^^^^^^^

.. attention:: `"Proxying is on by default when you onboard a domain via the dashboard." <https://developers.cloudflare.com/dns/proxy-status/>`__ Disable the proxy where relevant.

-  Proxy A, AAAA and CNAME records for web traffic to OCP servers.
-  Proxy A, AAAA and CNAME records for `URL forwarding <https://developers.cloudflare.com/rules/page-rules/how-to/url-forwarding/>`__.

   .. attention::

      If a service expects the client's IP, reconfigure it to use the `CF-Connecting-IP <https://developers.cloudflare.com/fundamentals/reference/http-headers/#cf-connecting-ip>`__ header: for example, `WordFence <https://www.wordfence.com/help/dashboard/options/>`__.

   .. attention::

      We configure Apache and Nginx to use the ``CF-Connecting-IP`` header. Remember to inform third-party administrators (like RBC Group) to do the same.

-  Don't proxy A, AAAA or CNAME records for web traffic to Qlik Sense.
-  Don't proxy A, AAAA or CNAME records for web traffic to third-party servers, like `GitHub Pages <https://github.com/orgs/community/discussions/22790>`__, `Netlify <https://answers.netlify.com/t/support-guide-why-not-proxy-to-netlify/8869>`__ or `Super <https://super.so/guides/using-super-with-cloudflare>`__.
-  `Ports for SSH and non-web protocols are closed. <https://blog.cloudflare.com/cloudflare-now-supporting-more-ports/>`__ Therefore:

   - **DO NOT** proxy A or AAAA records for hostnames, like ``ocp99``.
   - **DO NOT** proxy CNAME records for PostgreSQL endpoints.

.. tip:: If requests return HTTP 403, determine the reason in `Security Analytics <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/open-contracting.org/security/analytics/events>`__.

.. note:: Advanced Certificate Manager is required to order an advanced certificate for `sub-subdomains <https://developers.cloudflare.com/ssl/edge-certificates/universal-ssl/limitations/#full-setup>`__ (or to use `Total TLS <https://developers.cloudflare.com/ssl/edge-certificates/additional-options/total-tls/>`__).

Reference: `Cloudflare documentation <https://developers.cloudflare.com/dns/proxy-status/>`__

Records reference
^^^^^^^^^^^^^^^^^

.. seealso:: :ref:`monitor-dmarc-reports`

.. note:: ``MS=…`` TXT records For `Microsoft domain verification <https://learn.microsoft.com/en-us/microsoft-365/admin/get-help-with-domains/create-dns-records-at-any-dns-hosting-provider#recommended-verify-with-a-txt-record>`__ can be deleted.

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
     - ``cdn.credere``
     - ``cloudfront.net`` name
     - `AWS CloudFront <https://us-east-1.console.aws.amazon.com/cloudfront/v4/home?region=us-east-1#/distributions/E1NFC1BEGJ978N>`__
   * - CNAME
     - ``_….cdn.credere``
     - ``acm-validations.aws`` name
     - `AWS Certificate Manager <https://us-east-1.console.aws.amazon.com/acm/home?region=us-east-1#/certificates/a8b484c6-393a-41f5-82b4-e5c3c24ed008>`__
   * - CNAME
     - ``…._domainkey.noreply``
     - ``dkim.amazonses.com`` name
     - `Amazon SES <https://us-east-1.console.aws.amazon.com/ses/home?region=us-east-1#/identities/noreply.open-contracting.org>`__ domain
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
     - ``sign._domainkey``
     - DKIM key record
     - `SendPulse <https://sendpulse.com/knowledge-base/email-service/additional/email-authentication>`__
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

SSL/TLS
~~~~~~~

`Configure encryption mode <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/open-contracting.org/ssl-tls/configuration>`__ is set to *Full (Strict)* to prevent man-in-the-middle attacks, etc. This means that, if certificates don't renew, downtime will occur, unlike when set to *Full*. We get notifications for expiring certificates to mitigate this.

SSL/TLS is `configured <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/open-contracting.org/ssl-tls/edge-certificates>`__ to `match <https://github.com/open-contracting/deploy/blob/main/salt/apache/files/conf/letsencrypt.conf>`__ origin servers:

Cipher suites (if enabled)
  By security Level > Modern
Always Use HTTPS
  Checked
Minimum TLS Version
  TLS 1.2
HTTP Strict Transport Security (HSTS):
  Enable HSTS (Strict-Transport-Security)
    Checked
  Max Age Header (max-age)
    6 months (Recommended)
  Apply HSTS policy to subdomains (includeSubDomains)
    Checked
  Preload
    Checked

Security > Settings
~~~~~~~~~~~~~~~~~~~

Continuous script monitoring
  Checked
Manage your robots.txt
  Disable robots.txt configuration

.. note::

   -  **DO NOT** enable `Block AI bots <https://developers.cloudflare.com/bots/concepts/bot/#ai-bots>`__. Increasingly, users access our content via LLMs.
   -  **DO NOT** enable `Manage your robots.txt <https://developers.cloudflare.com/bots/additional-configurations/managed-robots-txt/>`__. Increasingly, users access our content via LLMs.
   -  **DO NOT** enable Bot fight mode. It `"cannot be customized, adjusted, or reconfigured via WAF custom rules" <https://developers.cloudflare.com/bots/get-started/bot-fight-mode/#considerations>`__ in order to, for example, `allow WordPress sites to reach themselves <https://www.wordfence.com/help/advanced/compatibility/>`__, allow all requests to ``https://standard.open-contracting.org/schema/`` from users and CI.

.. warning::

   When adding a domain, unchecking *Instruct AI bot traffic with robots.txt* sets *Manage your robots.txt* to "Content Signals Policy" instead of "Disable robots.txt configuration".

Speed
~~~~~

Settings
^^^^^^^^

Content Optimization
  Speed Brain
    Checked (see :ref:`cloudflare-rum`)
  Early Hints
    Checked
Protocol Optimization
  0-RTT Connection Resumption
    Checked

Smart Shield
^^^^^^^^^^^^

Use the wizard to check *Smart Tiered Cache*.

Caching > Configuration
~~~~~~~~~~~~~~~~~~~~~~~

Browser Cache TTL
  Respect Existing Headers

Rules > Overview
~~~~~~~~~~~~~~~~

To redirect a domain, use the *Redirect to a different domain* template.

Account-level
-------------

.. _cloudflare-rum:

Analytics & logs
~~~~~~~~~~~~~~~~

After migrating nameservers to Cloudflare:

Web analytics > Manage site > Real User Measurements (RUM)
  Enable, excluding visitor data in the EU

Pages
~~~~~

-  `Login to Cloudflare <https://dash.cloudflare.com>`__
-  Click the *Create application* button
-  Click the *Pages* tab
-  Click the *Get started* button for *Import an existing Git repository*

   -  Select the organization from the *GitHub account* dropdown
   -  Select the repository, `configuring access <https://github.com/organizations/open-contracting/settings/installations/42450303>`__ if needed
   -  Click the *Begin setup* button
   -  Set the *Project name* to the repository name
   -  Select the branch from the *Production branch* dropdown, e.g. ``build``, ``gh-pages`` or ``main``
   -  Click the *Save and Deploy* button

-  Click the *Custom domains* tab, Click the *Set up a custom domain* button, and follow the prompts

Miscellaneous
~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1

   * - Service
     - Used by
     - Domain
   * - `Turnstile <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/turnstile>`__
     - `Fluent Forms <https://www.open-spending.eu/wp-admin/admin.php?page=fluent_forms_settings#turnstile>`__ (also available for Highlight and Share)
     - open-spending.eu

.. tip:: When reading details in the `Audig logs <https://dash.cloudflare.com/db6be30e1a0704432e9e1e32ac612fe9/audit-log>`__, the `API documentation <https://developers.cloudflare.com/api/>`__ describes the ``resource`` values.
