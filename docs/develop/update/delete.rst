Remove Salt configuration
=========================

If you delete something from a file, it won't be removed from the server, in most cases. To remove it, after you :doc:`deploy<../../deploy/deploy>`:

Delete a file
-------------

Run, for example:

.. code-block:: bash

   ./run.py 'docs' file.remove /path/to/file-to-remove

Delete a line from a file
-------------------------

Run, for example:

.. code-block:: bash

   ./run.py 'docs' cmd.run "sed --in-place '/text to match/d' /path/to/file"

Delete a user
-------------

#. Move any files from the user's home directory and change their ownership

#. Add a temporary state, for example:

   .. code-block:: yaml

      analysis:
        user.absent:
          - purge: True

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'mytarget' state.sls_id analysis kingfisher

#. Remove the temporary state

.. note::

   The `purge <https://docs.saltproject.io/en/latest/ref/states/all/salt.states.user.html#salt.states.user.absent>`__ option will delete all of the user's files.

Delete a cron job
-----------------

#. Change ``cron.present`` to ``cron.absent`` in the Salt state
#. :doc:`Deploy the server<../../deploy/deploy>`
#. Delete the Salt state

Delete a service
----------------

`Stop <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.stop>`__ and `disable <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.upstart_service.html#salt.modules.upstart_service.disable>`__ the service. For example:

.. code-block:: bash

   ./run.py 'mytarget' service.stop myservice
   ./run.py 'mytarget' service.disable myservice

Delete any configuration files added by the service (for example, under ``sites-available`` and ``sites-enabled``, for Apache).

.. note::

   There is an `open issue <https://github.com/open-contracting/deploy/issues/211>`__ to make removing services easier.

Delete a package
----------------

`Remove a package and its configuration files <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.purge>`__, and `remove any of its dependencies that are no longer needed <https://docs.saltproject.io/en/latest/ref/modules/all/salt.modules.aptpkg.html#salt.modules.aptpkg.autoremove>`__.

To scrub packages, for example:

.. code-block:: bash

   ./run.py 'mytarget' pkg.purge libapache2-mod-proxy-uwsgi,uwsgi-plugin-python3,uwsgi
   ./run.py 'mytarget' pkg.autoremove list_only=True
   ./run.py 'mytarget' pkg.autoremove purge=True

Then, login to the server and check for and delete any remaining packages, files or directories relating to the package, for example:

.. code-block:: bash

   dpkg -l | grep uwsgi
   ls /etc/uwsgi
   find /usr -name '*uwsgi*'

.. _delete-firewall-setting:

Delete a firewall setting
-------------------------

#. Import the ``unset_firewall`` macro:

   .. code-block:: jinja

      {% from 'lib.sls' import unset_firewall %}

#. Add a temporary macro call, for example:

   .. code-block:: jinja

      {{ unset_firewall('PUBLIC_POSTGRESQL') }}

#. Deploy the relevant server, for example:

   .. code-block:: bash

      ./run.py 'mytarget' state.apply

#. Remove the temporary macro call

.. _delete-apache-module:

Delete an Apache module
-----------------------

#. Add a temporary state, for example:

   .. code-block:: yaml

      headers:
        apache_module.disabled

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'mytarget' state.sls_id headers core

#. Remove the temporary state

.. _delete-htpasswd-entry:

Delete an htpasswd entry
------------------------

#. Add a temporary state, for example:

   .. code-block:: yaml

      delete-NAME:
        webutil.user_absent:
          - htpasswd_file: /etc/apache2/.htpasswd-NAME

#. Run the temporary state, for example:

   .. code-block:: bash

      ./run.py 'mytarget' state.sls_id delete-NAME core

#. Remove the temporary state

.. _delete-apache-virtual-host:

Delete an Apache virtual host
-----------------------------

Run, for example:

.. code-block:: bash

   ./run.py 'cove' file.remove /etc/apache2/sites-enabled/cove.conf
   ./run.py 'cove' file.remove /etc/apache2/sites-available/cove.conf
   ./run.py 'cove' file.remove /etc/apache2/sites-available/cove.conf.include

A temporary ``apache_site.disabled`` state can be used instead of removing the file in the ``sites-enabled`` directory.

.. _delete-nginx-virtual-host:

Delete an Nginx virtual host
----------------------------

Run, for example:

.. code-block:: bash

   ./run.py 'mytarget' file.remove /etc/nginx/sites-enabled/mysite.conf
   ./run.py 'mytarget' file.remove /etc/nginx/sites-available/mysite.conf
   ./run.py 'mytarget' file.remove /etc/nginx/sites-available/mysite.conf.include

Delete a PostgreSQL user
------------------------

See :ref:`pg-delete-user`.
