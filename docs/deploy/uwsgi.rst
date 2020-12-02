Configuring uWSGI
=================

We use `uWSGI <https://uwsgi-docs.readthedocs.io/en/latest/>`__ to serve Python apps, mainly Django apps.

.. _django-apps:

Create a Django app
-------------------

#. In your app's state file, include the `django <https://github.com/open-contracting/deploy/blob/master/salt/django.sls>`__ state file:

   .. code-block:: yaml

      include:
        - django

#. In your app's Pillar file, set the variables that are commented out in the `django <https://github.com/open-contracting/deploy/blob/pillar/django.sls>`__ Pillar file.

All Django apps use the `uwsgi/files/django.ini <https://github.com/open-contracting/deploy/blob/master/salt/uwsgi/files/django.ini>`__ configuration template.

Example
~~~~~~~

An example app's Pillar file, with custom uWSGI settings:

.. code-block:: yaml

   # App user.
   user: example_user

   # App directory.
   # /home/$user/$name
   name: example_app

   apache:
     https: force
     servername: ex1.open-contracting.org

   git:
     url: https://github.com/open-contracting/example_django_app.git

   django:
     app: example_app
     env:
       EXAMPLE=value

   uwsgi:
     # Timeout in seconds per request (900 = 15 minutes).
     harakiri: 900
     # Limit memory usage in MB.
     limit-as: 1024
     # Total requests before worker is restarted. This helps address memory leaks.
     max-requests: 1024
     # Restart the worker if it finishes processing its request with 250MB or more in memory.
     reload-on-as: 250

Create a Python app
-------------------

Use the ``uwsgi`` macro defined in the `lib.sls <https://github.com/open-contracting/deploy/blob/master/salt/lib.sls>`__ file:

.. code-block:: yaml

   uwsgi(service, name='', port='', appdir='')

-  The ``service`` argument selects the uWSGI `configuration template <https://github.com/open-contracting/deploy/tree/master/salt/uwsgi/files/>`__. If this is a new service, you might need to create a new one.
-  The ``name`` argument defaults to the ``service`` argument, and controls the name of the application in ``/etc/uwsgi/apps-available/`` and ``/etc/uwsgi/apps-enabled/``.
-  The ``port`` and ``appdir`` arguments are passed through as context variables to render the configuration template (which might or might not use the variables).

If you need to create a uWSGI configuration template:

-  Design the template to get the values of uWSGI settings from the Pillar data.
-  If a value isn't in the Pillar data, it should either:

   -  Use a default value, for example:

      .. code-block:: jinja

         {{ salt['pillar.get']('uwsgi:max-requests', "1024") }}


   -  Ignore the value, for example:

      .. code-block:: jinja

         {%- if salt['pillar.get']('uwsgi:cheaper') %}
         cheaper = {{ salt['pillar.get']('uwsgi:cheaper') }}
         {%- endif %}
