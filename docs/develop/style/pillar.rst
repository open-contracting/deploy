Pillar style guide
==================

Order the top-level keys in these layers:

-  Meta

   -  System administration: ``maintenance``, ``system_contacts``
   -  Third-party service credentials: ``aws``, ``github``, ``google``, ``smtp``

-  Universal services

   -  Server access: ``network``, ``firewall``, ``ssh``
   -  Kernel: ``vm``
   -  Time: ``ntp``
   -  Monitoring: ``prometheus``
   -  Logging: ``rsyslog``, ``logrotate``
   -  Scheduling: ``cron``

-  Application services

   -  Web access: ``apache``
   -  Services: ``elasticsearch``, ``postgres``, ``mysql``, ``rabbitmq``
   -  Environments: ``docker``, ``nodejs``, ``rvm``
   -  Applications: ``docker_apps``, ``python_apps``, ``react_apps``
