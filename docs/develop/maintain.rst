Maintain
========

If you don't understand why a configuration exists, it's useful to check its history.

The files in this repository were originally in the `opendataservices-deploy <https://github.com/OpenDataServices/opendataservices-deploy>`__ repository. You can `browse <https://github.com/OpenDataServices/opendataservices-deploy/tree/7a5baff013b888c030df8366b3de45aae3e12f9e>`__ that repository from before the switchover (August 5, 2019). That repository was itself re-organized at different times. You can browse `before moving content from *.conf to *.conf.include <https://github.com/OpenDataServices/opendataservices-deploy/tree/4dbea5122e1fc01221c8d051efc99836cef98ccb>`__ (June 5, 2019).

Remove unneeded services and packages
-------------------------------------

We remove unneeded services and packages from this repository, because carrying old configurations forever into the future increases the maintenance burden of this repository.

If you don't know whether a package is still required, you can connect to the server and:

-  Show what files the package installs:

   .. code-block:: bash

      dpkg -L PACKAGE

-  Show what packages the package depends on:

   .. code-block:: bash

      apt show PACKAGE

-  Show what packages depends on this package:

   .. code-block:: bash

      apt rdepends PACKAGE

For example, the above commands show that ``redis`` is a metapackage (installing only documentation) that depends on ``redis-server``, and that ``python3-virtualenv`` provides library files whereas ``virtualenv`` provides a binary file (needed by Salt).

The ``./manage.py`` command has ``services`` and ``packages`` sub-commands to identify unusual services and packages, and an ``autoremove`` to list candidates for removal.
