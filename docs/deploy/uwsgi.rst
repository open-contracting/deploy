Configuring uWSGI
=================

We use uWSGI to host python based applications, mainly django.

Creating new uWSGI apps
~~~~~~~~~~~~~~~~~~~~~~~

.. note::

   If you are creating a django app you can skip this section. See `#django_apps`.

To set up a new uWSGI application you can use the uwsgi macro defined in `lib.sls <https://github.com/open-contracting/deploy/blob/master/salt/lib.sls>`.

You can pass the uwsgi macro a number of parameters to customise the install.

.. code-block::

   uwsgi(service, name='', port='', appdir='')

The ``service`` indicates the type of application it is hosting. 
This in turn chooses the uWSGI configuration file.
If this is a new service you may need to create a new config file. Configuration files are stored `here <https://github.com/open-contracting/deploy/tree/master/salt/uwsgi/configs/>`. 

The `port` and `appdir` settings are passed through and used to render the configuration file.
Not all of the parameters are used in the service configs so check the config to know which to set.
This list of parameters that the macro accepts can be manually extended as configs require new settings.


When creating uwsgi configs, they should be designed to query pillar for any uwsgi settings.
If it cannot find a setting, it should either set a sensible default or assume the setting is blank.

You can see an example where uwsgi settings are customised in the app pillar data below `#Example_configs`.


django apps
~~~~~~~~~~~

To set up a django app, you simply need to include the django state file from yours and update your config file. 
You can do this as follows:

.. code-block:: yml

   include:
     - django

And then update your pillar settings to include `these settings <https://github.com/open-contracting/deploy/blob/pillar/django_pillar.sls>`.

You can see what the ``django`` include sets up `here <https://github.com/open-contracting/deploy/blob/master/salt/django.sls>`.

All django apps use the `uwsgi/configs/django.ini <https://github.com/open-contracting/deploy/blob/master/salt/uwsgi/configs/django.ini>` config file.


Example configs
~~~~~~~~~~~~~~~

Below is an example django app with custom uwsgi settings. 

.. code-block:: yml

   # App user.
   user: exampleuser
   
   # App directory.
   # /home/$user/$app_dir
   name: example_app
   
   apache:
     servername: ex1.open-contracting.org
     https: both
   
   git:
     url: https://github.com/open-contracting/example_django_app.git
   
   django:
     app: example_app
     env:
       EXAMPLE=value
   
   uwsgi:
     # Timeout in seconds per request (900 = 15 minutes).
     haraki: 900
     # Limit memory usage in MB.
     limit-as: 1024
     # Total requests before worker is restarted.
     # This helps address memory leaks.
     max-requests: 1024
     # Restart the worker if it finishes processing its request with 250MB or more in memory.
     reload-on-as: 250


