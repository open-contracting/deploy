We use uWSGI to host python based applications, mainly django.


To set up a new uWSGI application you can use the uwsgi macro defined in [lib.sls](https://github.com/open-contracting/deploy/salt/lib.sls)

You can pass uwsgi a number of parameters.
> uwsgi(service, name='', port='', appdir='')

The service is the type of application it is hosting. 
This in turn chooses the configuration file.
If this is a new service you may need to create a new config file. 

All django apps are based off of this config:
> uwsgi/configs/django.ini


The `port` and `appdir` settings are passed through and used to render the configuration file.
Not all of the parameters are used in the service configs so check them to know which to set.

This list of parameters can be manually extended as configs require new settings.


The uwsgi configs should be designed to query pillar for any uwsgi settings.
If it cannot find a setting, it should either set a sensible default or assume the setting is blank.

Here is an example pillar file, defining settings for a django application:
https://github.com/open-contracting/deploy/pillar/examples/django_app.sls
