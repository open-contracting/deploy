Redmine tasks
=============

Enable admin user
-----------------

Dogsbody Technology uses the admin user to verify upgrades.

To enable the ``admin`` user:

.. code-block:: bash

   ./run.py 'redmine' mysql.query redmine 'UPDATE users SET status = 1, admin = 1 WHERE login = "admin"'

To disable the ``admin`` user:

.. code-block:: bash

   ./run.py 'redmine' mysql.query redmine 'UPDATE users SET status = 0, admin = 0 WHERE login = "admin"'

Open interactive consoles
-------------------------

#. Connect to the server as the ``redmine`` user:

   .. code-block:: bash

      curl --silent --connect-timeout 1 crm.open-contracting.org:8255 || true
      ssh redmine@crm.open-contracting.org

#. Change to the Redmine application's directory:

   .. code-block:: bash

      cd /home/redmine/public_html

#. Open an IRB console:

   .. code-block:: bash

      bundle exec rails console --environment=production

#. Or, open a MySQL console (password in ``config/database.yml``):

   .. code-block:: bash

      bundle exec rails dbconsole --environment=production

Debug email notifications
-------------------------

Read the email configuration:

.. code-block:: bash

   cat /var/data/redmine/config/configuration.yml

Open a Rails console and run:

.. code-block:: ruby

   user = User.where(login: 'jmckinney').first
   mailer = Mailer.test_email(user)
   mailer.deliver_now

When testing notifications, remember to uncheck *I don't want to be notified of changes that I make myself* on the `My account <https://crm.open-contracting.org/my/account>`__ page.

Cleanup old files
-----------------

Check changed, untracked and ignored files:

.. code-block:: bash

   cd /var/data/redmine
   svn diff
   svn status
   svn status --no-ignore | grep '^I' | grep -v tmp/

Expected untracked files are:

-  `Themes from RedmineUP <https://www.redmineup.com/pages/themes>`__

Expected ignore files include files under:

-  ``.bundle``
-  ``Gemfile.lock``
-  ``config/configuration.yml``
-  ``config/database.yml``
-  ``config/initializers/secret_token.rb``
-  ``db/schema.rb``
-  ``files/*``
-  ``log/*``
-  ``plugins/*``
-  ``public/plugin_assets`` belonging to current plugins, and ``redmine_crm``

You might need to:

-  Delete files from ``public/plugin_assets`` that relate to old plugins
-  Revert patched files
-  Delete patch files

After making changes, as root, run: ``systemctl restart apache2.service``

Reference
---------

What emails are imported
~~~~~~~~~~~~~~~~~~~~~~~~

In ``app/models/mail_handler.rb``, Redmine ignores these headers:

-  ``Auto-Submitted: auto-replied``
-  ``Auto-Submitted: auto-generated``
-  ``X-Autoreply: yes``

It also ignores:

-  Emails from the sending address to avoid cycles (data@open-contracting.org).
-  Emails from inactive users.

To check for ignored messages on the server:

.. code-block:: bash

   grep "MailHandler: ignoring" /var/data/redmine/log/production.log

The data@open-contracting.org GMail account should only have the following in its *Inbox*:

-  Unread messages (which will be imported)
-  Emails from data@ (when the CRM cc's data@)
-  Delivery status notifications (from before using Amazon SES)
-  Auto-responders (``Auto-Submitted: auto-replied``)
-  Calendar invitations (``Auto-Submitted: auto-generated``)
-  Eventbrite order notifications

The following filter can be used to find any others:

.. code-block:: none

   in:inbox after:2019/01/01 from:(-me) subject:(-"delivery status notification" -"no se puede entregar" -"undeliverable" -"automatic reply" -"respuesta automatica" -"resposta automatica" -"out of office" -"out of the office" -"away from office" -"I'm on annual leave until" -"auto" -"holiday" -"on leave" -"vacation" -"fuera de la oficina" -"absense du bureau" -"updated invitation" -"order notification for" -"notificación de registro para" -"notification d'inscription pour") -{"this is an automated reply" "Me encuentro de licencia" "fuera de la oficina"}

*Sent* should only contain emails from data@ in cases where the CRM cc'd data@.

Code snippets
~~~~~~~~~~~~~

View the names of the custom fields:

.. code-block:: ruby

   CustomField.all.map(&:name)

View the names of a class' relations (replace ``Model`` with the class name):

.. code-block:: ruby

   Model.reflections.keys

Find people:

.. code-block:: ruby

   names = [
     'Jane Doe',
     'John Doe',
   ]
   matches = names.select do |name|
     scope = Contact
     name.split(' ').each do |component|
       scope = scope.live_search(component)
     end
     scope.any?
   end

Country codes
~~~~~~~~~~~~~

The following gets the list of countries in Redmine:

.. code-block:: ruby

   country_codes = I18n.t(:label_crm_countries)

It includes the following, which aren't among the officially assigned codes of `ISO 3166-1 alpha 2 <https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2>`__:

User-assigned code:

-  ZZ Unknown or Invalid Region

   .. note::

      This is used for Kosovo, and for a small number of exceptional companies.

Deleted codes:

-  CT Canton and Enderbury Islands
-  DD East Germany
-  FQ French Southern and Antarctic Territories
-  JT Johnston Island
-  MI Midway Islands
-  NQ Dronning Maud Land
-  PC Pacific Islands Trust Territory
-  PU U.S. Miscellaneous Pacific Islands
-  PZ Panama Canal Zone
-  VD North Vietnam
-  WK Wake Island
-  YD People's Democratic Republic of Yemen

Transitionally reserved codes:

-  AN Netherlands Antilles
-  CS Serbia and Montenegro
-  NT Neutral Zone

Exceptionally reserved codes:

-  FX Metropolitan France
