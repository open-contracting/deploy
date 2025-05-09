Pillar style guide
==================

Order the top-level keys in these layers:

-  Meta

   -  System administration: ``maintenance``, ``system_contacts``
   -  Third-party service credentials: ``github``, ``google``, ``smtp``

-  Universal services

   -  Server access: ``network``, ``firewall``, ``ssh``
   -  Kernel: ``vm``
   -  Locale: ``locale``
   -  Time: ``ntp``
   -  Monitoring: ``netdata``, ``prometheus``
   -  Logging: ``rsyslog``, ``logrotate``
   -  Scheduling: ``cron``, ``backup``

-  Application services

   -  Infrastructure: ``aws``
   -  Web access: ``apache``, ``nginx``
   -  Services: ``elasticsearch``, ``mysql``, ``postgres``, ``rabbitmq``
   -  Environments: ``docker``, ``php``, ``nodejs``, ``rvm``
   -  Applications: ``docker_apps``, ``phpfpm``, ``python_apps``, ``react_apps``, ``wordpress``
