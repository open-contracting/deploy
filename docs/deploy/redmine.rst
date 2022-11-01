Redmine tasks
=============

The `Data Support CRM <https://crm.open-contracting.org>`__ uses `Redmine <https://www.redmine.org>`__.

.. seealso::

   :doc:`Redmine maintenance tasks<../maintain/redmine>`
   :ref:`Migrate a Redmine service to a new server<migrate-server>`

Upgrade Ruby
------------

#. Check the installed version of Ruby on the `Information <https://crm.open-contracting.org/admin/info>`__ page
#. Check which minor versions of Ruby are `supported <https://www.redmine.org/projects/redmine/wiki/RedmineInstall>`__ by the desired version of Redmine
#. :ref:`Change the default version of Ruby installed by RVM<rvm>`

Upgrade plugins
---------------

#. Click *Check for updates* on the `Plugins <https://crm.open-contracting.org/admin/plugins>`__ page
#. For `RedmineUP <https://www.redmineup.com>`__ plugins:

   #. Read the changelogs, checking for notable new features and Redmine version compatibility
   #. `Get access to the licence manager <https://www.redmineup.com/pages/help/pricing/downloading-updates>`__ with ``jmckinney@open-contracting.org``
   #. Download the latest versions of the PRO plugins in use from the `license manager <https://www.redmineup.com/license_manager>`__

#. For non-RedmineUP plugins:

   #. Read the changelogs, checking for notable new features and Redmine version compatibility
   #. Download the latest versions

#. Replace the plugin directories in the ``salt/private/files/redmine/`` directory with the new versions
#. Apply `our patches <https://github.com/open-contracting/miscellaneous-private-scripts/tree/master/redmine/patches>`__ to the plugin files
#. Commit and push your changes
#. :doc:`Deploy the service<deploy>`

Changelogs
~~~~~~~~~~

-  `view_customize <https://github.com/onozaty/redmine-view-customize/releases>`__
-  `redmine_agile <https://www.redmineup.com/pages/plugins/agile/updates>`__
-  `redmine_checklists <https://www.redmineup.com/pages/plugins/checklists/updates>`__
-  `redmine_contacts <https://www.redmineup.com/pages/plugins/crm/updates>`__ (CRM)
-  `redmine_contacts_helpdesk <https://www.redmineup.com/pages/plugins/helpdesk/updates>`__

Upgrade theme
-------------

#. Check that the `Circle theme <https://www.redmineup.com/pages/themes/circle>`__ is used via the `Display settings <https://crm.open-contracting.org/settings?tab=display>`__ page
#. Read its `changelog <https://www.redmineup.com/pages/themes/circle/updates>`__, checking for notable new features
#. Check whether the desired version of Redmine is `supported <https://www.redmineup.com/pages/themes/circle#requirements>`__
#. Download the latest version
#. Replace the theme's directory in the ``salt/private/files/redmine/`` directory
#. Commit and push your changes
#. :doc:`Deploy the service<deploy>`

Upgrade Redmine
---------------

Check `Redmine's documentation for supported MySQL versions <https://www.redmine.org/projects/redmine/wiki/redmineinstall>`__.

#. Check the installed version of Redmine on the `Information <https://crm.open-contracting.org/admin/info>`__ page

#. Read Redmine's `changelog <https://www.redmine.org/projects/redmine/wiki/Changelog>`__ for changes that might affect users

#. In ``salt/redmine/init.sls``, set ``branch`` and ``revision`` to the desired branch and current revision of the `official SVN repository <https://svn.redmine.org/redmine/branches/>`__

#. :doc:`Deploy the service<deploy>`

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 ocp16.open-contracting.org:8255 || true
      ssh root@ocp16.open-contracting.org

#. Change to the Redmine application's directory:

   .. code-block:: bash

      cd /home/redmine/public_html

#. Install Redmine's dependencies:

   .. code-block:: bash

      BUNDLER_WITHOUT="development test" bundle install

#. Generate Redmine's token (only on first install):

   .. code-block:: bash

      bundle exec rake generate_secret_token

#. Run database migrations:

   .. code-block:: bash

      RAILS_ENV=production bundle exec rake db:migrate
      RAILS_ENV=production bundle exec rake redmine:plugins:migrate

#. Patch the ``field_format.rb`` file:

   #. Modify ``/home/redmine/public_html/lib/redmine/field_format.rb``, removing ``::I18n.t('activerecord.errors.messages.inclusion')`` from line 788.

      .. code-block:: ruby

         784 def validate_custom_value(custom_value)
         785   values = Array.wrap(custom_value.value).reject {|value| value.to_s == ''}
         786   invalid_values = values - possible_custom_value_options(custom_value).map(&:last)
         787   if invalid_values.any?
         788     []
         789   else
         790     []
         791   end
         792 end

   .. note::

      This edit fixes a bug/incompatibility between redmine_contacts and Redmine 3.4.7.

#. Load in Redmine changes:

   .. code-block:: bash

      systemctl restart apache2.service

#. Ask the Data Support Team to :ref:`test-redmine`.

.. _test-redmine:

Test Redmine
------------

You must test Redmine's web, email and command-line interfaces.

Web interface
~~~~~~~~~~~~~

Setup
^^^^^

#. Click *My account*
#. Select *Only for things I watch or I'm involved in*
#. Uncheck *I don't want to be notified of changes that I make myself*
#. Click *Save*

Tests
^^^^^

#. Create a company contact, and add an individual contact to the company. Add tags to the contacts following the `contact requirements <https://crm.open-contracting.org/projects/ocds/wiki/Contact_requirements>`__.
#. Create an issue.

   #. Assign the issue to yourself. Check that an email notification is received.
   #. Add yourself as a watcher.
   #. Edit the issue, add a note, add the *New ticket checklist* from the template, and update the following fields. Check that an email notification is received:

      #. Project
      #. Tracker
      #. Subject
      #. Description
      #. Status
      #. Priority

   #. Edit the issue, check some items off the checklist, and add a new checklist item.

#. Edit the issue, and log time, populating all fields in the time entry. (`#4079 <https://crm.open-contracting.org/issues/4079>`__)
#. Log time against the issue by clicking *Log time* and populating all fields in the time entry.
#. Check all *View Customize* work, at least "Always expand To, Cc, Bcc addresses" and "Confirm recipients before sending email".

Views Customize
'''''''''''''''

.. note::

   An administrator can confirm the list of `Views Customize <https://crm.open-contracting.org/view_customizes>`__, if you lack permission.

-  Redirect from homepage to OCDS project.

   -  Check that accessing the bare domain redirects to ``/projects/ocds``.

These customizations have to do with the *Pipeline* tab.

-  Rename *Deals* to *Pipeline* and display as board by default.

   -  Check the label in the navigation bar. Check that the results are presented as a table of cards (like an agile board).

-  Hide deal values and contacts.

   -  Check that the cards include only a publisher name, and that there is no total value at the bottom of the table.

-  Hide deal value.

   -  Click on a card, and check that there is no value (like 0.0).

-  Do not change the table's background color on hover.

For these customizations, you can use ``/issues/864``:

-  Move *Agile boards*, *Helpdesk reports*, *Custom queries* to the bottom of the sidebar.
-  Add a *Respond by e-mail* link to the links at the top of the issue.
-  Hide quoted text by default.

   -  Note #2 should have "…Show quoted text…" links

-  Add *Initially addressed to* under *From* at the top of the issue.

For these customizations, you can use ``/issues/3227``:

-  Always expand *To*, *Cc*, *Bcc* addresses

   -  Check *Send note*, and check that the fields are visible

-  Confirm recipients before sending email

   -  Add analyst email addresses to *Cc* and *Bcc*, click *Submit*, and check the content of the dialog

Teardown
^^^^^^^^

If the tests were performed on the live server:

#. Delete the new issues, contacts and time entries you created.
#. Check *I don't want to be notified of changes that I make myself*.

If the tests were performed on a test server:

#. Access ``/issues?set_filter=1&f%5B%5D=&sort=updated_on%3Adesc`` to list recently updated issues, and check that you didn't accidentally:

   #. Use the test server as if it were the live server (e.g. responding to requests).
   #. Fetch messages that should have been fetched by the live server.

Email interface
~~~~~~~~~~~~~~~

.. tip::

   If using a test server, these tests need to be performed carefully. Mail that is fetched by the test server will not be re-fetched by the live server without intervention. If more than the test message is fetched by the test server, access GMail and mark any additional messages as unread, so that they will be re-fetched by the live server.

.. note::

   To test mail retrieval on a test server:

   #. Open the **live** server's `wiki page <https://crm.open-contracting.org/projects/ocds/wiki>`__
   #. Open the **test** server's wiki page at ``/projects/ocds/wiki``
   #. Draft an email to send from a non-work email address

   Wait for a time whose minute doesn't end in 4 or 9, to avoid the cron job on the live server fetching the mail first.

   Then, in quick succession, to reduce the likelihood of a partner's email being received at the same time:

   #. Click the *Fetch mail* link on the **live** server's wiki page
   #. Send the email
   #. Click the *Fetch mail* link on the **test** server's wiki page

   The JSON response should have a count of 1, and the expected issue should be updated.

#. Edit an issue, check *Send note*, add a non-work email address as a recipient, and submit. Check that an email (not a notification) is received.
#. Reply to the email (not any notification) from the non-work email address and check that the issue is updated.
#. Send an email with an attachment to data@open-contracting.org from a non-work email address. Check that an issue was created and that the attachment is associated.
#. *If using the live server:* Check that the cron job (which runs every 5 minutes) works, by sending an email as in the previous step and waiting 5 minutes.

   -  If the cron job isn't yet active, you can manually run the commands in ``/home/sysadmin-tools/bin/redmine_cron.sh``, which is called from ``/etc/cron.d/redmine``

   .. note::

      We couldn't get the Rake task to work in December 2018, so the cron job uses the manual fetch mail link.

Command-line interface
~~~~~~~~~~~~~~~~~~~~~~

Using `these commands <https://github.com/open-contracting/miscellaneous-private-scripts/tree/master/redmine#readme>`__:

#. Connect to the server
#. Set up your environment
#. Open a MySQL console, and run the SQL queries
#. Open a Rails console, and run the cleanup scripts
