Maintenance Guides
==================

To be responsible for servers, you should:

-  Subscribe to:

   -  `Sysadmin <https://groups.google.com/a/open-contracting.org/forum/#!forum/sysadmin>`__ mailing list (OCP only)
   -  Operating system security announcements (`Ubuntu <https://lists.ubuntu.com/mailman/listinfo/ubuntu-security-announce>`__)
   -  Hosting provider :ref:`network status announcements<hosting>`

-  :doc:`Upgrade packages<packages>` on a weekly basis
-  Check server monitoring, at a regular interval:

   -  :doc:`Check the resource usage <../use/prometheus>` and decide whether to :ref:`rescale<rescale-server>` or to investigate any abnormalities
   -  `Check the alerts configuration <https://monitor.prometheus.open-contracting.org/alerts>`__

-  Perform periodic server tasks, at a regular interval:

   -  :ref:`Review root access<review-root-access>`
   -  :ref:`Check mail<check-mail>`
   -  :ref:`Clean root user directory<clean-root-user-directory>`
   -  :doc:`Re-deploy services<../deploy/deploy>` to guarantee all changes are applied (optional)

-  :doc:`Check that backups are made<backup>`, at a regular interval

.. toctree::
   :caption: Contents
   :maxdepth: 2

   periodic.rst
   packages.rst
   databases.rst
   elasticsearch.rst
   rabbitmq.rst
   docker.rst
   network.rst
   hosting.rst
   backup.rst

.. toctree::
   :caption: Service-specific tasks
   :maxdepth: 2

   docs.rst
