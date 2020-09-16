Update server configurations
============================

Change server name
------------------

If the virtual host uses HTTPS, you will need to acquire SSL certificates for the new server name and remove the SSL certificates for the old server name.

#. Change the ``ServerName``
#. In the relevant Pillar file, change ``https`` to ``certonly``
#. :doc:`Deploy the service<deploy>`
#. In the relevant Pillar file, change ``https`` to ``force`` or ``both``
#. Remove the old SSL certificates, for example:

   .. code-block:: bash

      salt-ssh 'ocds-docs-staging' file.remove /etc/letsencrypt/live/dev.standard.open-contracting.org

To check for old SSL certificates that were previously not removed, run:

.. code-block:: bash

   salt-ssh '*' cmd.run 'ls /etc/letsencrypt/live'

.. _remove-content:

Remove content
--------------

If you delete a file, service, package, user, authorized key, Apache module, or virtual host from a file, it will not be removed from the server. To remove it, after you :doc:`deploy<deploy>`:

.. _delete-authorized-key:

Delete an authorized key
~~~~~~~~~~~~~~~~~~~~~~~~

#. Delete it from the relevant file in the ``salt/private/authorized_keys`` directory
#. Run, for example:

.. code-block:: bash

   salt-ssh '*' ssh.rm_auth_key root "AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q=="

.. The key is from https://git-scm.com/book/en/v2/Git-on-the-Server-Generating-Your-SSH-Public-Key

Delete a file
~~~~~~~~~~~~~

Run, for example:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' file.remove /path/to/file-to-remove

Delete a cron job
~~~~~~~~~~~~~~~~~

#. Change ``cron.present`` to ``cron.absent`` in the Salt state
#. Deploy the relevant service
#. Delete the Salt state

Delete a service
~~~~~~~~~~~~~~~~

`Stop <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.stop>`__ and `disable <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.disable>`__ the service.

To stop and disable the ``icinga2`` service on the ``ocds-docs-staging`` target, for example:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' service.stop icinga2
   salt-ssh 'ocds-docs-staging' service.disable icinga2

If you deleted the ``uwsgi`` service, also run, for example:

.. code-block:: bash

   salt-ssh 'cove-live-ocds-3' file.remove /etc/uwsgi/apps-available/cove.ini
   salt-ssh 'cove-live-ocds-3' file.remove /etc/uwsgi/apps-enabled/cove.ini

Delete a package
~~~~~~~~~~~~~~~~

`Remove a package and its configuration files <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.purge>`__, and `remove any of its dependencies that are no longer needed <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.autoremove>`__.

To scrub Icinga-related packages from the ``ocds-docs-staging`` target, for example:

.. code-block:: bash

   salt-ssh 'ocds-docs-staging' pkg.purge icinga2,nagios-plugins,nagios-plugins-contrib
   salt-ssh 'ocds-docs-staging' pkg.autoremove list_only=True
   salt-ssh 'ocds-docs-staging' pkg.autoremove purge=True

Then, login to the server and check for and delete any remaining packages, files or directories relating to the package, for example:

.. code-block:: bash

   dpkg -l | grep icinga
   dpkg -l | grep nagios
   ls /etc/icinga2
   ls /usr/lib/nagios

Delete an Apache module
~~~~~~~~~~~~~~~~~~~~~~~

#. Add a temporary state, for example:

   .. code-block:: none

      headers:
        apache_module.disabled

#. Deploy the relevant service, for example:

   .. code-block:: bash

      salt-ssh 'toucan' state.apply

#. Remove the temporary state

Delete a virtual host
~~~~~~~~~~~~~~~~~~~~~

Run, for example:

.. code-block:: bash

   salt-ssh 'cove-ocds-live-2' file.remove /etc/apache2/sites-enabled/cove.conf
   salt-ssh 'cove-ocds-live-2' file.remove /etc/apache2/sites-available/cove.conf
   salt-ssh 'cove-ocds-live-2' file.remove /etc/apache2/sites-available/cove.conf.include

You might also delete the SSL certificates as when :ref:`changing server name<change-server-name>`.

Delete a PostgreSQL user
~~~~~~~~~~~~~~~~~~~~~~~~

#. Connect to the Kingfisher database, and delete the given user from the ``views.read_only_user`` table, for example:

   .. code-block:: sql

      DELETE FROM views.read_only_user WHERE username = 'ocdskfpguest';

#. Add a temporary state, for example:

   .. code-block:: none

      ocdskfpguest:
        postgres_user.absent

#. Run the temporary state, for example:

   .. code-block:: bash

      salt-ssh 'kingfisher-process*' state.sls_id ocdskfpguest ocdskingfisherprocess

#. Remove the temporary state

If the state fails with "User ocdskfpguest failed to be removed":

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      ssh root@process.kingfisher.open-contracting.org

#. Attempt to drop the given user as the ``postgres`` user, for example:

   .. code-block:: bash

      su - postgres ocdskingfisherprocess -c 'psql -c "DROP ROLE ocdskfpguest;"'

#. You should see a message like:

   .. code-block:: none

      ERROR:  role "ocdskfpguest" cannot be dropped because some objects depend on it
      DETAIL:  privileges for table …
      …
      and 1234 other objects (see server log for list)

#. Open the server log, and search for the relevant ``DROP ROLE`` statement (after running the command below, press ``/``, type ``DROP ROLE``, press Enter, and press ``n`` until you match the relevant statement):

   .. code-block:: bash

      less /var/log/postgresql/postgresql-11-main.log

#. If all the objects listed after ``DETAIL:`` in the server log can be dropped (press Space to scroll forward), then press ``q`` to quit ``less`` and open a SQL terminal as the ``postgres`` user:

   .. code-block:: bash

      su - postgres ocdskingfisherprocess -c psql

#. Finally, delete the given user:

   .. code-block:: sql

      REASSIGN OWNED BY ocdskfpguest TO anotheruser;
      DROP OWNED BY ocdskfpguest;
      DROP ROLE ocdskfpguest;
