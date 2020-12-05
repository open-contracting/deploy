Update server configurations
============================

Avoid Pillar gotchas
--------------------

-  If unquoted, ``yes``, ``no``, ``true`` and ``false`` are parsed as booleans. Use quotes to parse as strings.
-  A blank value is parsed as ``None``. Use the empty string ``''`` to parse as a string.
-  Below, if ``a`` is equal to an empty string, then ``b`` will be ``None``:

   .. code-block:: jinja

      {% set extracontext %}
      b: {{ a }}
      {% endset %}

   Instead, surround it in quotes:

   .. code-block:: jinja

      {% set extracontext %}
      b: "{{ a }}"
      {% endset %}

Review packages
---------------

If you don't know whether a package is still required, you can connect to the server and:

-  Show what files the package installs:

   .. code-block:: bash

      dpkg -L PACKAGE

-  Show what packages the package depends on:

   .. code-block:: bash

      apt show PACKAGE

For example, the above commands show that ``redis`` is a metapackage (installing only documentation) that depends on ``redis-server``, and that ``python3-virtualenv`` provides library files whereas ``virtualenv`` provides a binary file.

.. _change-server-name:

Change server name
------------------

If the virtual host uses HTTPS, you will need to acquire SSL certificates for the new server name and remove the SSL certificates for the old server name.

#. Change the ``ServerName``
#. In the relevant Pillar file, change ``https`` to ``certonly``
#. :doc:`Deploy the service<deploy>`
#. In the relevant Pillar file, change ``https`` to ``force``
#. Remove the old SSL certificates, for example:

   .. code-block:: bash

      ./run.py 'docs' file.remove /etc/letsencrypt/live/dev.standard.open-contracting.org

To check for old SSL certificates that were previously not removed, run:

.. code-block:: bash

   ./run.py '*' cmd.run 'ls /etc/letsencrypt/live'

.. _remove-content:

Remove content
--------------

If you delete a file, service, package, user, authorized key, Apache module, or virtual host from a file, it will not be removed from the server. To remove it, after you :doc:`deploy<deploy>`:

Delete a file
~~~~~~~~~~~~~

Run, for example:

.. code-block:: bash

   ./run.py 'docs' file.remove /path/to/file-to-remove

Delete a line from a file
~~~~~~~~~~~~~~~~~~~~~~~~~

Run, for example:

.. code-block:: bash

   ./run.py 'docs' cmd.run "sed --in-place '/text to match/d' /path/to/file"

Delete a cron job
~~~~~~~~~~~~~~~~~

#. Change ``cron.present`` to ``cron.absent`` in the Salt state
#. Deploy the relevant service
#. Delete the Salt state

Delete a service
~~~~~~~~~~~~~~~~

`Stop <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.stop>`__ and `disable <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.disable>`__ the service.

To stop and disable the ``icinga2`` service on the ``docs`` target, for example:

.. code-block:: bash

   ./run.py 'docs' service.stop icinga2
   ./run.py 'docs' service.disable icinga2

If you deleted the ``uwsgi`` service, also run, for example:

.. code-block:: bash

   ./run.py 'cove-ocds' file.remove /etc/uwsgi/apps-available/cove.ini
   ./run.py 'cove-ocds' file.remove /etc/uwsgi/apps-enabled/cove.ini

Delete a package
~~~~~~~~~~~~~~~~

`Remove a package and its configuration files <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.purge>`__, and `remove any of its dependencies that are no longer needed <https://docs.saltstack.com/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.autoremove>`__.

To scrub Icinga-related packages from the ``docs`` target, for example:

.. code-block:: bash

   ./run.py 'docs' pkg.purge icinga2,nagios-plugins,nagios-plugins-contrib
   ./run.py 'docs' pkg.autoremove list_only=True
   ./run.py 'docs' pkg.autoremove purge=True

Then, login to the server and check for and delete any remaining packages, files or directories relating to the package, for example:

.. code-block:: bash

   dpkg -l | grep icinga
   dpkg -l | grep nagios
   ls /etc/icinga2
   ls /usr/lib/nagios

Delete a firewall setting
~~~~~~~~~~~~~~~~~~~~~~~~~

#. Import the ``unset_firewall`` macro:

   .. code-block:: jinja

      {% from 'lib.sls' import unset_firewall %}

#. Add a temporary macro call, for example:

   .. code-block:: jinja

      {{ unset_firewall("PUBLIC_POSTGRESQL") }}

#. Deploy the relevant service, for example:

   .. code-block:: bash

      ./run.py 'kingfisher-process' state.apply

#. Remove the temporary macro call

Delete an Apache module
~~~~~~~~~~~~~~~~~~~~~~~

#. Add a temporary state, for example:

   .. code-block:: yaml

      headers:
        apache_module.disabled

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'toucan' state.sls_id headers core

#. Remove the temporary state

Delete a virtual host
~~~~~~~~~~~~~~~~~~~~~

Run, for example:

.. code-block:: bash

   ./run.py 'cove-ocds' file.remove /etc/apache2/sites-enabled/cove.conf
   ./run.py 'cove-ocds' file.remove /etc/apache2/sites-available/cove.conf
   ./run.py 'cove-ocds' file.remove /etc/apache2/sites-available/cove.conf.include

You might also delete the SSL certificates as when :ref:`changing server name<change-server-name>`.

Delete a PostgreSQL user
~~~~~~~~~~~~~~~~~~~~~~~~

#. Connect to the Kingfisher database, and delete the given user from the ``views.read_only_user`` table, for example:

   .. code-block:: sql

      DELETE FROM views.read_only_user WHERE username = 'ocdskfpguest';

#. Add a temporary state, for example:

   .. code-block:: yaml

      ocdskfpguest:
        postgres_user.absent

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'kingfisher-process' state.sls_id ocdskfpguest kingfisher-process

#. Remove the temporary state

If the state fails with "User ocdskfpguest failed to be removed":

#. Connect to the server as the ``root`` user, for example:

   .. code-block:: bash

      curl --silent --connect-timeout 1 process.kingfisher.open-contracting.org:8255 || true
      ssh root@process.kingfisher.open-contracting.org

#. Attempt to drop the given user as the ``postgres`` user, for example:

   .. code-block:: bash

      su - postgres -c 'psql ocdskingfisherprocess -c "DROP ROLE ocdskfpguest;"'

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

      su - postgres -c 'psql ocdskingfisherprocess'

#. Finally, delete the given user:

   .. code-block:: sql

      REASSIGN OWNED BY ocdskfpguest TO anotheruser;
      DROP OWNED BY ocdskfpguest;
      DROP ROLE ocdskfpguest;

Check history
-------------

If you don't understand why a configuration exists, it's useful to check its history.

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. You can `browse <https://github.com/OpenDataServices/opendataservices-deploy/tree/7a5baff013b888c030df8366b3de45aae3e12f9e>`__ that repository from before the switchover (August 5, 2019). That repository was itself re-organized at different times. You can browse `before moving content from *.conf to *.conf.include <https://github.com/OpenDataServices/opendataservices-deploy/tree/4dbea5122e1fc01221c8d051efc99836cef98ccb>`__ (June 5, 2019).
