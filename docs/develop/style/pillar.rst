Pillar style guide
==================

Order the top-level keys in these layers:

-  Meta
   -  System administration: ``maintenance``, ``system_contacts``
   -  Third-party service credentials: ``github``, ``google``, ``smtp``

-  Universal services

-  Server access: ``network``, ``firewall``, ``ssh``
  -  Kernel: ``vm``
  -  Time: ``ntp``
  -  Monitoring: ``prometheus``
  -  Logging: ``rsyslog``, ``logrotate``

-  Application services

   -  Web access: ``apache``
   -  Services: ``elasticsearch``, ``postgres``, ``rabbitmq``
   -  Environments: ``docker``, ``nodejs``
   -  Applications: ``docker_apps``, ``python_apps``, ``react_apps``
