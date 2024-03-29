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
   -  Monitoring: ``prometheus``
   -  Logging: ``rsyslog``, ``logrotate``
   -  Scheduling: ``cron``

-  Application services

   -  Infrastructure: ``aws``
   -  Web access: ``apache``
   -  Services: ``elasticsearch``, ``postgres``, ``mysql``, ``rabbitmq``
   -  Environments: ``docker``, ``nodejs``, ``rvm``
   -  Applications: ``docker_apps``, ``python_apps``, ``react_apps``
