Configure Python apps
=====================

The ``python_apps`` state file performs common operations for Python apps. In your app's state file, include it with:

.. code-block:: yaml

   include:
     - python_apps

If you already have an ``include`` state, add ``python_apps`` to its list.

Add basic configuration
-----------------------

In the service's Pillar file, add, for example:

.. code-block:: yaml

   python_apps:
     kingfisher_summarize:
       user: summarize
       git:
         url: https://github.com/open-contracting/kingfisher-summarize.git
         branch: main
         target: kingfisher-summarize

This will:

-  Install packages for creating Python virtual environments
-  Fetch the git repository into the ``target`` directory within the home directory of the ``user``
-  Initialize a virtual environment in a ``.ve`` directory within the repository's directory
-  Install ``requirements.txt`` with ``pip-sync`` from `pip-tools <https://pypi.org/project/pip-tools/>`__
-  Reload uWSGI (if configured below) if the repository's contents changed

Add configuration files
-----------------------

To create configuration files within the user's ``.config`` directory, add, for example:

.. code-block:: yaml
   :emphasize-lines: 8-9

   python_apps:
     kingfisher_summarize:
       user: summarize
       git:
         url: https://github.com/open-contracting/kingfisher-summarize.git
         branch: main
         target: kingfisher-summarize
       config:
         kingfisher-summarize/logging.json: salt://kingfisher/summarize/files/logging.json

You can add as many configuration files as you like.

.. _django-configure:

Configure Django
----------------

If the Python app uses the Django framework, add, for example:

.. code-block:: yaml
   :emphasize-lines: 8-13

   python_apps:
     myapp:
       user: myuser
       git:
         url: https://github.com/open-contracting/myrepo.git
         branch: main
         target: myuser
       django:
         app: ocdsmyapp
         compilemessages: True
         env:
           ALLOWED_HOSTS: mysubdomain.open-contracting.org
           FATHOM_ANALYTICS_ID: ABCDEFGH

This will activate the virtual environment, and run, using ``--settings {app}.settings``:

-  The `migrate <https://docs.djangoproject.com/en/3.2/ref/django-admin/#django-admin-migrate>`__ management command
-  The `collectstatic <https://docs.djangoproject.com/en/3.2/ref/contrib/staticfiles/#collectstatic>`__ management command
-  The `compilemessages <https://docs.djangoproject.com/en/3.2/ref/django-admin/#compilemessages>`__ management command, if ``compilemessages`` is truthy

Set a ``SECURE_HSTS_SECONDS`` environment variable according to `Django's documentation <https://docs.djangoproject.com/en/3.2/ref/middleware/#http-strict-transport-security>`__.

Generate a ``SECRET_KEY`` environment variable for the private Pillar file by running, in your Django project:

.. code-block:: bash

   python manage.py shell -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'

.. seealso::

   :ref:`Migrate a Django application to a new server<migrate-server>`

Configure uWSGI
---------------

`uWSGI <https://uwsgi-docs.readthedocs.io/en/latest/>`__ is used to serve Python apps.

Add, for example:

.. code-block:: yaml
   :emphasize-lines: 4-5

   python_apps:
     myapp:
       # ...
       uwsgi:
         configuration: django

This will:

-  Install the uWSGI service
-  Create a ``/etc/uwsgi/apps-available/{target}.ini`` file
-  Symlink the new file from the ``/etc/uwsgi/apps-enabled`` directory
-  Reload the uWSGI service if the configuration changed

The example above uses the `django <https://github.com/open-contracting/deploy/blob/main/salt/uwsgi/files/django.ini>`__ configuration, which:

-  Sets the uWSGI ``module`` to ``{app}.wsgi:application``
-  Sets some environment variables, and any ``env`` variables from the service's Pillar file

   .. warning::

      During deployment, uWSGI reloads rather than restarts. However, deleted environment variables are not unset during reload. To remove a variable from the environment, you must :ref:`restart uWSGI<restart-service>`.

-  Sets default values for some uWSGI settings, and supports custom values for other uWSGI settings, which you can override or set, for example:

   .. code-block:: yaml
      :emphasize-lines: 6

      python_apps:
        myapp:
          # ...
          uwsgi:
            configuration: django
            harakiri: 1800

The default values are:

harakiri
  Timeout in seconds per request. Default: ``900`` (15 minutes).
max-requests
  Number of requests before a worker is reloaded. This can help address memory leaks. Default: ``1000``.
max-worker-lifetime
  Number of seconds before a worker is reloaded. This can help address memory leaks. Default: ``3600`` (1 hour).
worker-reload-mercy
  The maximum time for a worker to reload/shutdown. Default: ``60`` (1 minute).
limit-as
  Limit uWSGI memory usage, in MB. Default: 3/4 of RAM. This assumes no other process uses significant memory.
reload-on-rss
  Reload a worker (after processing a request) if using too much memory, in MB. Default: ``256``.

Alternatively, you can write your own configuration file in ``salt/uwsgi/files``, and reference it from the ``configuration`` variable.

Configure Apache
----------------

Apache is used as a reverse proxy to uWSGI.

Add, for example:

.. code-block:: yaml
   :emphasize-lines: 4-9

   python_apps:
     myapp:
       # ...
       apache:
         configuration: django
         servername: mysubdomain.open-contracting.org
         serveraliases: ['main.{{ grains.fqdn }}']
         context:
           assets_base_url: ''

This will:

-  Install the Apache service
-  Enable the :ref:`mod_proxy, mod_proxy_http and mod_proxy_uwsgi<apache-modules>` Apache modules
-  Perform the same steps as :ref:`adding an Apache site<apache-sites>`, but creating files named ``/etc/apache2/sites-available/{target}.conf`` and ``/etc/apache2/sites-available/{target}.conf.include``.

The example above uses the `django <https://github.com/open-contracting/deploy/blob/main/salt/apache/files/sites/django.conf.include>`__ configuration, which:

-  Sets the ``DocumentRoot`` to the ``target`` directory
-  Configures Apache to serve Django's static and media files, from the ``assets_base_url`` if provided
-  Configures the reverse proxy to the uWSGI service, using uWSGI's ``harakiri`` setting as the ``timeout`` value
-  Includes a file matching the app's name from the ``salt/apache/includes`` directory, if any

Alternatively, you can write your own configuration file in ``salt/apache/files/sites``, and reference it from the ``configuration`` variable.

To make the Python app publicly accessible, :ref:`allow HTTP/HTTPS traffic<allow-http>`.
